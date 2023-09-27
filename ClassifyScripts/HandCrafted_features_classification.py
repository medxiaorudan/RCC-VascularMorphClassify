#!/usr/bin/env python
# coding: utf-8
# Author: Rudan XIAO

# Import libraries
import os
import subprocess
import time
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler
from sklearn.tree import export_graphviz
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.ensemble import AdaBoostClassifier, RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.metrics import classification_report, log_loss, hamming_loss, mean_squared_error, roc_curve, auc
from sklearn.metrics import matthews_corrcoef, f1_score, precision_score, recall_score, accuracy_score, confusion_matrix
from sklearn.utils import shuffle
from mwutil.ml import run_training_range, compare_classifiers

rand_state = np.random.RandomState(32)
scoring_function_label = 'f1_weighted'
scoring_function = f1_score

n_folds = 3
classifiers = {}
n_stages = 55
subsample_n = -1

def predict_patient_slices(slices):
    y=model.predict(slices)
    p1=sum(y)/len(y)
    p=[1-p1,p1]
    label=np.argmax(p)
    return label

#when input are all group of slices
def predict_patient(dict_group):
    patient_label = []
    for keys,values in dict_group.items():
        y=values['predict_label']
        p1 = sum(y)/len(y)
        p = [1-p1,p1]
        label_predict = np.argmax(p)
        label_true = np.array(values['true_label'])[0:1]
        patient_label.append([int(keys),label_predict,label_true])
        t = pd.DataFrame(patient_label)
        t.columns = ['patient_id','label_predict','label_true']
    return t

#find bad data of all group of slices based on threshold
def get_bad_data(dict_group,theta):
    res=[]
    for key,value in dict_group.items():
        y=value['predict_label']
        right=(y==value['true_label'])
        p=sum(right)/len(right)
        if p<theta:
            res.append(key)
    return res

## Confusion Matricies
def confusion_matrix_patient(dict_group,patient_label_true):
    patient_label_predict = []
    for keys,values in dict_group.items():
        y=values['predict_label']
        p1 = sum(y)/len(y)
        p = [1-p1,p1]
        label_predict = np.argmax(p)
        patient_label_predict.append(label_predict)
        pd.DataFrame(patient_label_predict)
    cm = confusion_matrix(patient_label_true, patient_label_predict)
    cm_nor = np.empty(shape=[2, 2])
    cm_nor[0][0]=cm[0][0]/(cm[0][0]+cm[1][0])
    cm_nor[0][1]=cm[1][0]/(cm[0][0]+cm[1][0])
    cm_nor[1][0]=cm[1][0]/(cm[0][1]+cm[1][1])
    cm_nor[1][1]=cm[1][1]/(cm[0][1]+cm[1][1])
    return cm_nor

def main():
    start = time.time()
    # set path to dataset
    train_data_path = 'D:/test_vascular_mask/test/all_features200_all.csv'
    test_data_path = 'D:/test_vascular_mask/test/all_features_smooth.csv'

    df_train = pd.read_csv(train_data_path)
    df_test = pd.read_csv(test_data_path)

    df_train.dropna(inplace=True)
    df_train.reset_index(drop=True,inplace=True)
    df_test.dropna(inplace=True)
    df_test.reset_index(drop=True,inplace=True)

    df_train = shuffle(df_train)
    df_test = shuffle(df_test)

    df_train.columns=['ID','NE','small_NE','big_NE','NJ', 'LE', 'LJ', 'NE/NJ', 
                'LE/LJ', 'NJ/(LJ+LE)','LJ/(LJ+LE)','NE/(LJ+LE)', 'mean_Area', 'median_Area', 'mean_Perimeter', 
                'median_Perimeter', 'mean_Eccentricity', 'median_Eccentricity','density','case','class']
    df_test.columns=['ID','NE','small_NE','big_NE', 'NJ', 'LE', 'LJ', 'NE/NJ', 
                'LE/LJ', 'NJ/(LJ+LE)','LJ/(LJ+LE)','NE/(LJ+LE)', 'mean_Area', 'median_Area', 'mean_Perimeter', 
                'median_Perimeter', 'mean_Eccentricity', 'median_Eccentricity','density','class']

    # split X (features), y (PD stage label) from the dataframe
    features = ['NE', 'small_NE','big_NE','NJ', 'LE', 'LJ', 'NE/NJ', 
                'LE/LJ', 'NJ/(LJ+LE)','LJ/(LJ+LE)','NE/(LJ+LE)','mean_Area', 'median_Area', 'mean_Perimeter', 
                'median_Perimeter', 'mean_Eccentricity', 'median_Eccentricity','density']

    X_train = df_train[features]
    X_test = df_test[features]

    scaler = StandardScaler().fit(X_train)
    X_train = pd.DataFrame(scaler.transform(X_train), columns = X_train.columns)
    X_test = pd.DataFrame(scaler.transform(X_test), columns = X_test.columns)

    y_train = df_train['class']
    y_test = df_test['class']

    df=df_test
    X=X_test


    # set path to dataset
    train_data_path = 'D:/test_vascular_mask/test/all_features200_filted1.csv'
    test_data_path = 'D:/test_vascular_mask/test/all_features_manually _filted.csv'

    df_train = pd.read_csv(train_data_path)
    df_test = pd.read_csv(test_data_path)

    df_train.dropna(inplace=True)
    df_train.reset_index(drop=True,inplace=True)
    df_test.dropna(inplace=True)
    df_test.reset_index(drop=True,inplace=True)

    df_train = shuffle(df_train)
    df_test = shuffle(df_test)

    df_train.columns=['ID','NE','big_NE','NJ', 'LE', 'LJ', 'NE/NJ', 
                'NJ/(LJ+LE)', 'mean_Area', 'median_Area', 
                'median_Perimeter', 'mean_Eccentricity', 'median_Eccentricity','density','case','class']
    df_test.columns=['ID','NE','big_NE', 'NJ', 'LE', 'LJ', 'NE/NJ', 
               'NJ/(LJ+LE)', 'mean_Area', 'median_Area',
                'median_Perimeter', 'mean_Eccentricity', 'median_Eccentricity','density','class']

    # split X (features), y (PD stage label) from the dataframe
    features = ['NE', 'big_NE','NJ', 'LE', 'LJ', 'NE/NJ', 
                'NJ/(LJ+LE)', 'mean_Area', 'median_Area', 
                'median_Perimeter', 'mean_Eccentricity', 'median_Eccentricity','density']

    X_train = df_train[features]
    X_test = df_test[features]

    scaler = StandardScaler().fit(X_train)
    X_train = pd.DataFrame(scaler.transform(X_train), columns = X_train.columns)
    X_test = pd.DataFrame(scaler.transform(X_test), columns = X_test.columns)

    y_train = df_train['class']
    y_test = df_test['class']

    df=df_test
    X=X_test

    test_data_path = 'D:/TCGA/use/order_RCC_TCGA/all_features_smooth_2class.csv'
    df_test = pd.read_csv(test_data_path)
    df_test.dropna(inplace=True)
    df_test.reset_index(drop=True,inplace=True)
    df_test = shuffle(df_test)

    df_test.columns=['ID','NE','big_NE', 'NJ', 'LE', 'LJ', 'NE/NJ', 
               'NJ/(LJ+LE)', 'mean_Area', 'median_Area',
                'median_Perimeter', 'mean_Eccentricity', 'median_Eccentricity','density','class']
    X_test = df_test[features]
    X_test = pd.DataFrame(scaler.transform(X_test), columns = X_test.columns)
    y_test = df_test['class']
    df=df_test

    classifiers={'AdaBoost': AdaBoostClassifier(algorithm='SAMME.R', base_estimator=None,
               learning_rate=1.0, n_estimators=181,
              random_state=rand_state),
     'DecisionTree': DecisionTreeClassifier(class_weight=None, criterion='gini', max_depth=8,
                 max_features=None, max_leaf_nodes=None, min_samples_leaf=1,
                 min_samples_split=2, min_weight_fraction_leaf=0.0,
                 
                 random_state=rand_state,
                 splitter='best'),
     'Gradient Boosting Trees': GradientBoostingClassifier(init=None, learning_rate=0.1, loss='deviance',
                   max_depth=3, max_features=None, max_leaf_nodes=None,
                   min_samples_leaf=1, min_samples_split=2,
                   min_weight_fraction_leaf=0.0, n_estimators=299,
                   
                   random_state=rand_state,
                   subsample=1.0, verbose=0, warm_start=False),
     'KNN': KNeighborsClassifier(algorithm='auto', leaf_size=30, metric='minkowski',
                metric_params=None, n_jobs=1, n_neighbors=35, p=2,
                weights='uniform'),
     'Logistic Regression': LogisticRegression(C=1.0, class_weight=None, dual=False, fit_intercept=True,
               intercept_scaling=1, max_iter=6, multi_class='ovr', n_jobs=1,
               penalty='l2', random_state=rand_state,
               solver='liblinear', tol=0.0001, verbose=0, warm_start=False),
     'Random Forest': RandomForestClassifier(bootstrap=True, class_weight=None, criterion='gini',
                 max_depth=None, max_features='auto', max_leaf_nodes=None,
                 min_samples_leaf=1, min_samples_split=2,
                 min_weight_fraction_leaf=0.0, n_estimators=219, n_jobs=1,
                 oob_score=False,
                 random_state=rand_state, verbose=0,
                 warm_start=False),
     'svm_rbf': SVC(C=451, cache_size=200, class_weight='balanced', coef0=0.0,
       decision_function_shape="ovo", degree=3, gamma=0.01, kernel='rbf',
       max_iter=-1, probability=False,
       random_state=rand_state, shrinking=True,
       tol=0.001, verbose=False),
     'svm_sigmoid': SVC(C=1.0, cache_size=200, class_weight='balanced', coef0=0.0,
       decision_function_shape="ovo", degree=3, gamma=0.001, kernel='sigmoid',
       max_iter=-1, probability=False,
       random_state=rand_state, shrinking=True,
       tol=0.001, verbose=False)}

    fig, axs = plt.subplots(3,3)
    fig.set_size_inches(20,18)
    for i, (label, clf) in enumerate(zip(classifiers.keys(), classifiers.values())):
        
        clf.fit(X_train, y_train)
        predict_label_train = clf.predict(X_train)
        train_dataframe = pd.DataFrame({'ID':df_train['ID'],'case':df_train['case'],'true_label':y_train,'predict_label':predict_label_train})
        train_dataframe.sort_values(by=['case'],ascending=True,inplace=True)
        predict_label_test = clf.predict(X_test)
        test_dataframe = pd.DataFrame({'ID':df_test['ID'],'case':df_test['case'],'true_label':y_test,'predict_label':predict_label_test})
        test_dataframe.sort_values(by=['case'],ascending=True,inplace=True)
        patient_label_true_train = train_dataframe['true_label'].astype(float).groupby(train_dataframe['case']).mean()
        patient_label_true_test = test_dataframe['true_label'].astype(float).groupby(test_dataframe['case']).mean()
        dict_train={}
        for index, row in train_dataframe.iterrows():
            id = row['case']
            if id in dict_train.keys():
                dict_train[id]=dict_train[id].append([row], ignore_index=True)
            else:
                dict_train[id]= pd.DataFrame([row])

        dict_test={}
        for index, row in test_dataframe.iterrows():
            id = row['case']
            if id in dict_test.keys():
                dict_test[id]=dict_test[id].append([row], ignore_index=True)
            else:
                dict_test[id]= pd.DataFrame([row])  
            
        cm_df = confusion_matrix_patient(dict_test,patient_label_true_test)
        sns.heatmap(cm_df, ax=axs.flat[i], cmap="jet", annot=True, annot_kws={'size':19,'weight':'bold', 'color':'white'})
        axs.flat[i].set_title(label,fontsize=20)


    all_dataframe = pd.DataFrame({'ID':df['ID'],'case':df['case'],'NE':X['NE'],'small_NE':X['small_NE'],'big_NE':X['big_NE'], 'NJ':X['NJ'], 'LE':X['LE'], 'LJ':X['LJ'], 'NE/NJ':X['NE/NJ'], 
                 'LE/LJ':X['LE/LJ'],'NJ/(LJ+LE)':X['NJ/(LJ+LE)'],'LJ/(LJ+LE)':X['LJ/(LJ+LE)'],'NE/(LJ+LE)':X['NE/(LJ+LE)'], 
                 'mean_Area':X['mean_Area'], 'median_Area':X['median_Area'], 'mean_Perimeter':X['mean_Perimeter'], 
                 'median_Perimeter':X['median_Perimeter'], 'mean_Eccentricity':X['mean_Eccentricity'], 
                 'median_Eccentricity':X['median_Eccentricity'],'density':X['density'],'true_label':df['class']})

    all_dataframe.sort_values(by=['case'],ascending=True,inplace=True)


    all_dataframe_filterd = pd.DataFrame({'ID':df['ID'],'case':df['case'],'NE':X['NE'],'big_NE':X['big_NE'], 'NJ':X['NJ'], 'LE':X['LE'], 'LJ':X['LJ'], 'NE/NJ':X['NE/NJ'], 
                 'NJ/(LJ+LE)':X['NJ/(LJ+LE)'],
                 'mean_Area':X['mean_Area'], 'median_Area':X['median_Area'],
                 'median_Perimeter':X['median_Perimeter'], 'mean_Eccentricity':X['mean_Eccentricity'], 
                 'median_Eccentricity':X['median_Eccentricity'],'density':X['density'],'true_label':df['class']})

    all_dataframe.sort_values(by=['case'],ascending=True,inplace=True)

    RandomForest=RandomForestClassifier(bootstrap=True, class_weight=None, criterion='gini',
                 max_depth=None, max_features='auto', max_leaf_nodes=None,
                 min_samples_leaf=1, min_samples_split=2,
                 min_weight_fraction_leaf=0.0, n_estimators=219, n_jobs=1,
                 oob_score=False,
                 random_state=rand_state, verbose=0,
                 warm_start=False)

    confusion_matrix(y_test, RandomForest.predict(X_test)) 

    test_data_path = 'D:/TCGA/use/order_RCC_TCGA/all_features_smooth_2class.csv'
    df_test = pd.read_csv(test_data_path)
    df_test.dropna(inplace=True)
    df_test.reset_index(drop=True,inplace=True)
    df_test = shuffle(df_test)

    df_test.columns=['ID','NE','big_NE', 'NJ', 'LE', 'LJ', 'NE/NJ', 
               'NJ/(LJ+LE)', 'mean_Area', 'median_Area',
                'median_Perimeter', 'mean_Eccentricity', 'median_Eccentricity','density','class']
    X_test = df_test[features]
    X_test = pd.DataFrame(scaler.transform(X_test), columns = X_test.columns)
    y_test = df_test['class']
    df=df_test


    fig, axs = plt.subplots(3,3)
    fig.set_size_inches(20,18)
    for i, (label, clf) in enumerate(zip(classifiers.keys(), classifiers.values())):
        clf.fit(X_train, y_train.astype('int32'))
        M = confusion_matrix(y_test, clf.predict(X_test)) 
        M_nor=np.empty(shape=[2,2])
        M_nor[0][0]=M[0][0]/(M[0][0]+M[1][0])
        M_nor[0][1]=M[1][0]/(M[0][0]+M[1][0])
        M_nor[1][0]=M[0][1]/(M[0][1]+M[1][1])
        M_nor[1][1]=M[1][1]/(M[0][1]+M[1][1])
        sns.heatmap(M, ax=axs.flat[i], cmap="jet", annot=True, annot_kws={'size':19,'weight':'bold', 'color':'white'})
        axs.flat[i].set_title(label,fontsize=20)
    plt.show()

    fig, axs = plt.subplots(3,3)
    fig.set_size_inches(20,18)
    for i, (label, clf) in enumerate(zip(classifiers.keys(), classifiers.values())):
        clf.fit(X_train, y_train.astype('int32'))
        M = confusion_matrix(y_test, clf.predict(X_test)) 
        M_nor=np.empty(shape=[2,2])
        M_nor[0][0]=M[0][0]/(M[0][0]+M[1][0])
        M_nor[0][1]=M[1][0]/(M[0][0]+M[1][0])
        M_nor[1][0]=M[0][1]/(M[0][1]+M[1][1])
        M_nor[1][1]=M[1][1]/(M[0][1]+M[1][1])
        sns.heatmap(M, ax=axs.flat[i], cmap="jet", annot=True, annot_kws={'size':19,'weight':'bold', 'color':'white'})
        axs.flat[i].set_title(label,fontsize=20)
    plt.show()

    fig, axs = plt.subplots(3,3)
    fig.set_size_inches(20,18)
    for i, (label, clf) in enumerate(zip(classifiers.keys(), classifiers.values())):
        clf.fit(X_train, y_train.astype('int32'))
        cm_df = confusion_matrix(y_test, clf.predict(X_test))
        preds = max(clf.predict(X_test),1)
        correct+=sum(preds[:,1]==y_test[:,1])
        print("acc:{}".format(1.0*correct/y_test.shape[0])    
        cm_df_nor=np.empty(shape=[2,2])
        cm_df_nor[0][0]=cm_df[0][0]/(cm_df[0][0]+cm_df[0][1])
        cm_df_nor[0][1]=cm_df[0][1]/(cm_df[0][0]+cm_df[0][1])
        cm_df_nor[1][0]=cm_df[1][0]/(cm_df[1][0]+cm_df[1][1])
        cm_df_nor[1][1]=cm_df[1][1]/(cm_df[1][0]+cm_df[1][1])
        sns.heatmap(cm_df, ax=axs.flat[i], cmap="jet", annot=True, annot_kws={'size':19,'weight':'bold', 'color':'white'})
        axs.flat[i].set_title(label,fontsize=20) 
    plt.show()
    
if __name__ == "__main__":
    main()
