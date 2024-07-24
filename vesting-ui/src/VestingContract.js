import React, { useState, useEffect } from "react";
import Web3 from "web3";
import VestingContract from "./contracts/VestingContract.json";

const VestingApp = () => {
    const [web3, setWeb3] = useState(null);
    const [accounts, setAccounts] = useState([]);
    const [contract, setContract] = useState(null);
    const [amount, setAmount] = useState(0);

    useEffect(() => {
        const init = async () => {
            const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
            const accounts = await web3.eth.requestAccounts();
            const networkId = await web3.eth.net.getId();
            const deployedNetwork = VestingContract.networks[networkId];
            const instance = new web3.eth.Contract(
                VestingContract.abi,
                deployedNetwork && deployedNetwork.address,
            );

            setWeb3(web3);
            setAccounts(accounts);
            setContract(instance);
        };

        init();
    }, []);

    const claimTokens = async () => {
        await contract.methods.claimTokens().send({ from: accounts[0] });
        const balance = await contract.methods.balanceOf(accounts[0]).call();
        setAmount(balance);
    };

    return (
        <div>
            <h2>Vesting Contract</h2>
            <button onClick={claimTokens}>Claim Tokens</button>
            <p>Claimed Amount: {amount}</p>
        </div>
    );
};

export default VestingApp;
