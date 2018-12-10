import sys
import glob
import numpy as np
import read_zrsc2019
# takes output from BEER with and split it into separate onehot format for submission : 
# in:
# 0107_400123_0000.txt
#     0 0 0 0 0 0 1 0 0
#     0 0 0 0 0 1 0 0 0
#     0 0 0 0 0 1 0 0 0
#     0 1 0 0 0 0 0 0 0
#     0 0 0 1 0 0 0 0 0
# out: ossian format, phonemes of two characters only 
# 0107_400123_0000.txt
#     3312125645
# if phoneme of lenght one, append a letter after

def main(onehot_dir,dest_dir,text_corpora_path=None):
    text_corpora=''
        for filepath in glob.iglob(onehot_dir+'/*.txt'):
            read_zrsc2019.read(filepath) # check if input has the right format
            
        print("Files have the right format for synthesis")
        for filepath in glob.iglob(onehot_dir+'/*.txt'):
        with open(filepath,'r') as f:
        data=f.read()
        onehot_list= data.split('\n')
        sentence=''
        previous_unit='xx'
        for i in range(len(onehot_list)):
        if len(onehot_list[i])==0:
            continue
        onehot=[int(x) for x in onehot_list[i].split(' ')]
        unit=str(np.nonzero(onehot)[0].item())
        assert int(unit)<100 ,"This tool works only for list of phonemes of size <=100"
        if len(unit)==1:
            unit+='x'  
        if unit==previous_unit:
            previous_unit=unit
            continue
        sentence+=unit
        previous_unit=unit
        text_corpora+=sentence+' '
        with open(dest_dir+'/'+filepath.split('/')[-1], 'w') as myfile:
        myfile.write(sentence+'\n') 

    text_corpora+='\n'
        if text_corpora_path != None :
        with open(text_corpora_path,'w') as myfile:
            myfile.write(text_corpora)

                                                          
if __name__ == "__main__":

   print("onehot folder:",sys.argv[1],"ossian destination folder:",sys.argv[2])
   onehot_dir=sys.argv[1]
   dest_dir=sys.argv[2]
   text_corpora_path=None
   if len(sys.argv)==4:
       text_corpora_path=sys.argv[3]
   main(onehot_dir,dest_dir,text_corpora_path)

