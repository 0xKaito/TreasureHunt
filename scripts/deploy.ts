import { ethers } from "hardhat";

async function main() {

  const admin = process.env.ADMIN;
  if (!admin) {
    console.log("Provide admin address");
    return;
}

  const TreasureHunt = await ethers.getContractFactory("TreasureHunt");
  const treasureHunt = await TreasureHunt.deploy();

  console.log(
    `TreasureHunt deployed to ${treasureHunt.target}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
