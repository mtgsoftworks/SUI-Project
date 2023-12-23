# SUI-Project

Project Explanation and Aim:

The LegID project aims to create and manage LegID NFTs (Non-Fungible Tokens) on the blockchain. LegID NFTs represent unique products with specific information, such as the manufacturer, collection number, and transaction history. The project enables the creation of LegID NFTs by approved manufacturers and facilitates the transfer of ownership between buyers and sellers. The goal is to provide a secure and transparent system for verifying the authenticity and ownership of physical products.

Devnet Contract Address:

The devnet contract address for the LegID project is not provided in the code. You will need to deploy the contract to a devnet environment to obtain the contract address.

Project Setup:

To set up the LegID project, you need to follow these steps:

Install the Sui programming language by following the instructions in the Sui Docs.
Create a new project directory on your local machine.
Initialize a new Sui project in the project directory using the command: sui init.
Copy the code from the legIDModule module provided in your question and save it in a file named legIDModule.su.
Create a new file named main.su in the project directory and import the legIDModule module using the code: import "legIDModule.su".
Write your main function code in the main.su file to interact with the LegID module.
Running the Project:

To run the LegID project after setting it up, you can use the following command in the project directory:

Copy
sui run main.su
This will execute the main function in the main.su file and interact with the LegID module.

Testing the Project:

To test the LegID project, you can write test cases for the functions in the legIDModule module. You can create a new test file, for example, legIDModule_test.su, and write test cases using the Sui testing framework. Here's an example of a test case for the create_NFT function:

rust
Copy
import "legIDModule.su"

test "create_NFT should create a new LegID NFT" {
    let manuCap = ManuCapabilities { id: 1 }
    let name = vector::from_string("Product Name")
    let description = vector::from_string("Product Description")
    let url = vector::from_string("https://example.com/product")
    let collectionNumber = 1
    let ctx = TxContext { sender: @0x123, epoch: 1 }
    
    create_NFT(&manuCap, name, description, url, collectionNumber, &ctx)
    
    // Add assertions to check if the NFT is created successfully
    // For example:
    // assert!(...)
}
You can run the tests using the following command:

Copy
sui test legIDModule_test.su
