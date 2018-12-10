import glob
import numpy as np
import sys
from sklearn import preprocessing
# Takes embeddings from submission (one state every 10ms):
# in : 
#   0107_400123_0000.txt : (one_hot_vector)
#       possibletime1 0 0 0 1 0 0 0 
#       possibletime2 0 0 0 0 0 1
#       possibletime3 1 0 0 0 0 0
# out : a numpy file with two keys. "features" contains a 2-D matrix with 
#       feature along the column and times along the axis. 
#       "time" contains the middle time for each phoneme
#          
#       0107_400123_0000.npz :
#       features:[[possibletime1 0 0 0 1 0 0 0],
#             [possibletime20 0 0 0 0 0 1],
#             [possibletime3 1 0 0 0 0 0]])  
#       time:[0,0.5,1]


def main(init_dir,dest_dir):

    # Getting data from prep_evaluation_files's output
    for f in glob.iglob(init_dir+"/*.txt"):
        with open(f, 'r') as myfile:
            data=myfile.read()
        u_split=data.split('\n')	
        time=[]
        features=[]
        for i in range(len(u_split)):
            unit_data=u_split[i].split(' ') 
            if len(unit_data)==1:
                continue
            #start,end=unit_data[0].split(':')
            #onehot = unit_data[1:]          
            #time.append(float(start)+(float(end)-float(start))/2)
            time.append(i/(len(u_split)-1))
            features.append([float(x) for x in unit_data]) 
        filename=f.split('/')[-1].split('.')[0]
        np.savez(dest_dir+'/'+filename+'.npz', features=features, time=time)

if __name__ == '__main__':

   print("init dir:",sys.argv[1]," dest folder:",sys.argv[2])
   init_dir=sys.argv[1]
   dest_dir=sys.argv[2]
   main(init_dir,dest_dir)
