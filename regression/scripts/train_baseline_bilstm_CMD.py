import sys
sys.path.append('/home/srallaba/hacks/repos/clustergen_steroids')
from dynet_modules.AutoEncoders import *
import dynet as dy
import numpy as np
from math import sqrt
from sklearn import preprocessing
import random
from sklearn.metrics import mean_squared_error, accuracy_score, confusion_matrix

# This is to detect codemixing and not LID

arch = 'file_LID'
src_files_english = os.listdir('../data/english/cleaned')
src_files_spanish = os.listdir('../data/spanish/cleaned')
src_files_miami = os.listdir('../data/miami/cleaned')

files = []
labels = []

limit = 5000000

for (fc,file) in enumerate(src_files_english):
  if fc < limit: 
    files.append('../data/english/cleaned/' + file)
    labels.append(0)
for (fc,file) in enumerate(src_files_spanish):
  if fc < limit:
    files.append('../data/spanish/cleaned/' + file)
    labels.append(0)

limit = 100000000

for (fc,file) in enumerate(src_files_miami):
  if fc < limit:
    files.append('../data/miami/cleaned/' + file)
    labels.append(1)

data = zip(files, labels)

# Train test split
train =[]
test = []
c = 0
for d in data:
   c +=1
   if c%10 == 1:
     test.append(d)
   else:
     train.append(d)

num_toprint = int( 0.08 * len(train))

# Hyperparameters for the AE
units_input = 39
units_hidden = int(16)
units_output = 2
units_latent = int(16)

# Instantiate AE and define the loss
m = dy.Model() # EncoderBiLSTM_file
ae = EncoderBiLSTM_file(m, units_input, units_hidden, units_output, units_latent, dy.rectify)
trainer = dy.AdamTrainer(m)
update_params = 32

c = len(train)
# Loop over the training instances and call the AE
for epoch in range(30):
  train_loss = 0
  count = 1
  random.shuffle(train)
  for (f,l) in train:
#      print count, " of ", c
      k = np.loadtxt(f)
      if len(k) < 2:
         print "THis is unusual ", f
         continue
      count += 1
      recons_loss = ae.calc_loss_basic(f,l)
      #loss = dy.esum([kl_loss, recons_loss])
      loss = recons_loss
      train_loss += loss.value()
      if count % num_toprint == 1:
         print "  Loss at epoch ", epoch, " after " , count, " of ", c, " examples is ", float(train_loss/count)
         ae.save('models/' +  arch) 
         #pickle.dump(input_scaler, open('models/' + arch + '/input_scaler', 'wb'))
         random.shuffle(test)
         y_true = []
         y_pred = []
         for (ft,lt) in test[1:10]:
            label_predicted = ae.predict_label(ft)
            #print np.argmax(label_predicted.value()),lt, ft
            y_true.append(lt)
            y_pred.append(np.argmax(label_predicted.value()))
         #print accuracy_score(y_true, y_pred)   


      loss.backward()
      if count % update_params == 1:
        trainer.update() 
  print "Reconstruction Loss after epoch ", epoch , " : ", float(recons_loss.value()/count)
  print "Total Loss: ", float(train_loss/count)
  y_true = []
  y_pred = []

  for (ft,lt) in test:
    k = np.loadtxt(ft)
    if len(k) < 2:
       print "THis is unusual ", ft
       continue
    label_predicted = ae.predict_label(ft)
    #print np.argmax(label_predicted.value()), ft
    y_true.append(lt)
    y_pred.append(np.argmax(label_predicted.value()))
  print "           Test Accuracy:  ", accuracy_score(y_true, y_pred)   
  print "           Confusion Matrix: " , confusion_matrix(y_true, y_pred)
