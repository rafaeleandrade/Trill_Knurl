# Trill_Knurl  How to send your Ugens to bela | How to use Trill on bela with the TrillUgen 

// 0. Download the files at this repository (provided by Jonathan Reus)


// 1. open the Terminal an type

     cd /Users/rafaelemariaandrade/Desktop/TrillBela\(jonreus_github\)  (the root to your you file)


// 2. Transfer file to bela

     scp ./* root@bela.local
     or
     scp ./* root@192.168.7.2:/
      
 

//3. Enter to bela

      ssh root@bela.local
 
 
//4. Go inside the extensio folder

     cd /usr/local/share/SuperCollider/Extensions


//5. Transfering .so files to Extension folder

   cp /*.so .

//6. Transfering .sc files to Extension folder

   cp /*.sc .


//7. Check if everything is there typying:
     ls

//8. Done! Recompile and have fun!


Good luck for the future Trill-craft projects on bela!
