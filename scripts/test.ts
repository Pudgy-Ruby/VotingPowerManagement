import { ethers } from "hardhat";

const main = async () => {
  const TestFactory = await ethers.getContractFactory("Test");
  const test = await TestFactory.attach(
    "0xEd353d5E52574B7F75643f463583589dbd256A15"
  );
  await test.approveUnverified(
    "0xdc31ee1784292379fbb2964b3b9c4124d8f89c60",
    "0xC68214550de25c696C15909544348c845ceBA6dD",
    0
  );
};

main()
  .then(() => process.exit(0))
  .catch((err) => console.log(err));
