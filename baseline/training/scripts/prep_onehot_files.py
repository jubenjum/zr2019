import numpy as np
import sys
from sklearn import preprocessing
# Takes output from Beer (one state every 10ms):
# in : 
#   0107_400123_0000 au12 au12 au12 au33 au33 au56 au56 au56 
# and produce following output depending on the mode parameter
# mode bitrate out:
#   0107_400123_0000.txt : (start: end on_hot_vector)
#       0:0.03 0 0 0 1 0 0 0 
#       0.03:0.05 0 0 0 0 0 1
#       0.05:0.08 1 0 0 0 0 0
# or
# mode abx out : a numpy file with two keys. "features" contains a 2-D matrix with 
#       feature along the column and times along the axis. 
#       "time" contains the middle time for each phoneme
#           
#       0107_400123_0000.npz :
#       features:[[0 0 0 1 0 0 0],
#             [0 0 0 0 0 0 1],
#             [1 0 0 0 0 0]])  
#       time:[0.015,0.04,0.065]


def main(txt_file,dest_dir,mode,length_onehot):

    FRAME_LENGTH=0.01 # State length is 10ms in Beer
    with open(txt_file, 'r') as myfile:
        data=myfile.read()
    data_array=data.split('\n')

    data=[]
    # Getting data from BEER's output
    for w in range(len(data_array)):
        w_split= data_array[w].split(' ')
        if w_split==['']:
                continue
        sentence_id =w_split[0]
        filename = sentence_id
        w_split=w_split[1:] # getting rid of sentence_id
        previous_state=''
        start=0
        end=0
        length=FRAME_LENGTH
        previous_length=0
        previous_end=0
        previous_state=w_split[0] #getting first element beforehand
        w_split=w_split[1:]
        for i in range(len(w_split)):
            current_state=w_split[i]
            if previous_state==current_state:
                length+=FRAME_LENGTH
                continue
            start=previous_end
            end=start+length            
            data.append([filename,"{:.2f}".format(start),"{:.2f}".format(end),previous_state.split('u')[1]])
            previous_state=current_state
            length=FRAME_LENGTH
            previous_end=end
        # saving last symbol
        data.append([filename,"{:.2f}".format(end),"{:.2f}".format(end+length),current_state.split('u')[1]])

    # Build one hot vectors from units's labels
    data=np.asarray(data)
    #le = preprocessing.LabelEncoder()
    #numerical_label=le.fit_transform(data[:,3])
    #sentence=[str(start)+":"+str(end)+" "+previous_state+"\n"
    #encoder=preprocessing.OneHotEncoder()
    #onehots=encoder.fit_transform(numerical_label.reshape(-1,1)).toarray()

    # Write files for each sentences with one ht vectors
    previous_filename=data[0,0]
    sentence=''
    features=[]
    time=[]
    for i in range(data.shape[0]):
        filename=data[i,0]
        if filename!=previous_filename:
            if mode=='txt':
                with open(dest_dir+'/'+previous_filename+'.txt', 'w') as myfile:   
                    myfile.write(sentence)
            if mode=='npz':
                np.savez(dest_dir+'/'+previous_filename+'.npz', features=features, time=time)
            time=[]
            features=[]
            previous_filename=filename
            sentence='' 
        onehot=np.zeros((int(length_onehot),),dtype=int)
        onehot[int(data[i,3])-1]=1
        onehot_str=' '.join(str(x) for x in onehot)
        start=data[i,1]
        end=data[i,2]
        sentence+=start+":"+end+" "+onehot_str+"\n"
        time.append(float(start)+(float(end)-float(start))/2)
        #features.append([float(x) for x in onehots[i]]) 
        features.append(onehot) 
    #storing last file
    if mode=='txt':
        with open(dest_dir+'/'+filename+'.txt', 'w') as myfile:
                    myfile.write(sentence)
    if mode=='npz':
        np.savez(dest_dir+'/'+filename+'.npz', features=features, time=time)

if __name__ == '__main__':

   print("init raw text file:",sys.argv[1]," abx folder:",sys.argv[2]," bitrate folder:",sys.argv[3]," mode:",sys.argv[3]," number of aud:",sys.argv[4])
   txt_file=sys.argv[1]
   dest_dir=sys.argv[2]
   mode=sys.argv[3] # abx or bitrate
   length_onehot=sys.argv[4]
   main(txt_file,dest_dir,mode,length_onehot)
