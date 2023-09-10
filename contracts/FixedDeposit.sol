// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
contract FixedDeposit{
   struct FD{
       address creator;
       address customer;
       string title;
       uint256 principal;
       uint256 rate;
       uint256 time;
       uint256 interest;
       uint256 amount;
       address[]customers;
       uint256[]amountCollected;
   }
      mapping(uint256=>FD)public fds;
      uint256 public numberOfFds=0;
      function createFD(address _creator,string memory _title,uint256 _principal,uint256 _rate, uint256 _time)public returns(uint256){
          FD storage fd=fds[numberOfFds];
          fd.creator=_creator;
          fd.title=_title;
          fd.principal=_principal;
          fd.rate=_rate;
          fd.time=_time;
          numberOfFds++;
          return numberOfFds-1;

      }
      function subscribeFD(uint256 _id)public payable{
          FD storage fd=fds[_id];
          fd.customer=msg.sender;
          uint256 amt=msg.value;
          //send value equal to required principal
          require(amt==fd.principal,"The deposited amount should be equal to or greater than principal");
          
          fd.customers.push(fd.customer);
          (bool sent, )=payable(fd.creator).call{value:amt}("");
          if(sent){
          fd.interest=((fd.principal)*(fd.rate)*(fd.time))/100;
          fd.amount=fd.amount+fd.interest;
          fd.amountCollected.push(fd.amount);
          }
      }
      function getMaturityAmount(uint256 _id)public payable{
          FD storage fd=fds[_id];
          for(uint i=0;i<fd.customers.length;i++){
              require((fd.customers[i]==msg.sender)&&(fd.time==block.timestamp));
              uint256 amt2=fd.amount;
              require(amt2>0);
               (bool sent,)=payable(msg.sender).call{value:amt2}("");
             if(sent){
                
                  fd.amount=fd.amount-amt2;
                  

          }


      }
}
      function getCustomers(uint256 _id)view public returns(address[]memory,uint256[]memory){
          return(fds[_id].customers,fds[_id].amountCollected);

      }
      function getFDs()public view returns(FD[]memory){
          FD[] memory allfds=new FD[](numberOfFds);
          for(uint i=0;i<numberOfFds;i++){
              FD storage item=fds[i];
              allfds[i]=item;

          }
          return allfds;
    
      }
}