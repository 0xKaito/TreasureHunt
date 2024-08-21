// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

contract TreasureHunt {
    uint8 public constant GRID_SIZE = 10;
    uint8 public treasurePosition;
    uint256 public round;
    uint256 public prizePool;
    address public winner;

    mapping(address => uint8) public playerPositions;
    mapping(address => bool) public hasMoved;

    event PlayerMoved(address indexed player, uint8 position);
    event TreasureMoved(uint8 newPosition);
    event GameWon(address indexed winner, uint256 prize);

    constructor() {
        treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.number))) % (GRID_SIZE * GRID_SIZE));
        round = 1;
    }

    modifier onlyOncePerRound() {
        require(!hasMoved[msg.sender], "Player has already moved this round.");
        _;
    }

    modifier validMove(uint8 newPosition) {
        require(newPosition < GRID_SIZE * GRID_SIZE, "Invalid move.");
        _;
    }

    function move(uint8 newPosition) public payable onlyOncePerRound validMove(newPosition) {
        require(msg.value > 0, "Must send ETH to participate.");

        playerPositions[msg.sender] = newPosition;
        prizePool += msg.value;
        hasMoved[msg.sender] = true;

        emit PlayerMoved(msg.sender, newPosition);

        if (newPosition == treasurePosition) {
            _winGame();
        } else {
            _moveTreasure(newPosition);
        }
    }

    function _moveTreasure(uint8 playerPosition) internal {
        if ((playerPosition & 0xF) == 0) {
            treasurePosition = _getRandomAdjacentPosition(treasurePosition);
        } else if (_isPrime(playerPosition)) {
            treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % (GRID_SIZE * GRID_SIZE));
        }

        emit TreasureMoved(treasurePosition);
    }

    function _winGame() internal {
        winner = msg.sender;
        uint256 reward = (prizePool * 90) / 100;
        payable(winner).transfer(reward);
        prizePool = address(this).balance; // Remaining 10% stays for the next round
        emit GameWon(winner, reward);
        _resetGame();
    }

    function _resetGame() internal {
        round++;
        treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.number))) % (GRID_SIZE * GRID_SIZE));
        for (address player : _getAllPlayers()) {
            hasMoved[player] = false;
        }
    }

    function _getAllPlayers() internal view returns (address[] memory) {
        // To implement: return a list of all players who have participated
    }

    function _getRandomAdjacentPosition(uint8 currentPosition) internal view returns (uint8) {
        uint8[4] memory possibleMoves = [currentPosition - 1, currentPosition + 1, currentPosition - GRID_SIZE, currentPosition + GRID_SIZE];
        return possibleMoves[uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 4];
    }

    function _isPrime(uint8 num) internal pure returns (bool) {
        if (num <= 1) return false;
        for (uint8 i = 2; i * i <= num; i++) {
            if (num % i == 0) return false;
        }
        return true;
    }
}