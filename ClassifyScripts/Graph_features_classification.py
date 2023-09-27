#!/usr/bin/env python
# coding: utf-8
# Author: Rudan XIAO

import os
import urllib
import torch
import torch.nn as nn
import torch.nn.init as init
import torch.nn.functional as F
import torch.utils.data as data
import torch.optim as optim
import numpy as np
import scipy.sparse as sp
from zipfile import ZipFile
from sklearn.model_selection import train_test_split
import pickle
import pandas as pd
import torch_scatter
from collections import Counter
import torch_scatter

def tensor_from_numpy(x, device):
    return torch.from_numpy(x).to(device)


def normalization(adjacency):
    """Calculate L=D^-0.5 * (A+I) * D^-0.5,
    Args:
        adjacency: sp.csr_matrix.
    Returns:
        Normalized adjacency matrix, type is torch.sparse.FloatTensor
    """
    adjacency += sp.eye(adjacency.shape[0])    # Add self-connection
    degree = np.array(adjacency.sum(1))
    d_hat = sp.diags(np.power(degree, -0.5).flatten())
    L = d_hat.dot(adjacency).dot(d_hat).tocoo()
    indices = torch.from_numpy(np.asarray([L.row, L.col])).long()
    values = torch.from_numpy(L.data.astype(np.float32))
    tensor_adjacency = torch.sparse.FloatTensor(indices, values, L.shape)
    return tensor_adjacency


class RCCDataset(object):
 
    def __init__(self, data_root="D:/test_vascular_mask/test/"):
        self.data_root = data_root
#        self.maybe_download()
        sparse_adjacency_train, node_labels_train, graph_indicator_train, train_label = self.read_data_train()
        sparse_adjacency_test, node_labels_test, graph_indicator_test, test_label = self.read_data_test()
        
        self.sparse_adjacency_train = sparse_adjacency_train.tocsr()
        self.sparse_adjacency_test = sparse_adjacency_test.tocsr()
        
        self.node_labels_train = node_labels_train
        self.node_labels_test = node_labels_test
        
        self.graph_indicator_train = graph_indicator_train
        self.graph_indicator_test = graph_indicator_test
                
        self.train_index= np.asarray(list(set(self.graph_indicator_train)))
        self.test_index = np.asarray(list(set(self.graph_indicator_test)))
        
        self.train_label = train_label
        self.test_label = test_label

    
    def __getitem__(self, index):
        mask = self.graph_indicator == index
        node_labels = self.node_labels[mask]
        graph_indicator = self.graph_indicator[mask]
        graph_labels = self.graph_labels[index]
        adjacency = self.sparse_adjacency[mask, :][:, mask]
        return adjacency, node_labels, graph_indicator, graph_labels
    
    def __len__(self):
        return len(self.graph_labels)
    
    def read_data_train(self):
        data_dir = os.path.join(self.data_root, "SKEL_graph_features_train")
        print(data_dir)
        print("Loading SKEL_A.txt")
        adjacency_list = np.genfromtxt(os.path.join(data_dir, "SKEL_A.txt"),
                                       dtype=np.int64, delimiter=',') - 1
        print(adjacency_list)
        
        print("Loading SKEL_node_labels.txt")
        node_labels = np.genfromtxt(os.path.join(data_dir, "SKEL_node_labels.txt"), 
                                    dtype=np.int64) - 1
        print(node_labels)    
            
        print("Loading SKEL_graph_indicator.txt")
        graph_indicator = np.genfromtxt(os.path.join(data_dir, "SKEL_graph_indicator.txt"), 
                                        dtype=np.int64) - 1
        print(graph_indicator) 
        
        print("Loading SKEL_graph_labels.txt")
        graph_labels = np.genfromtxt(os.path.join(data_dir, "SKEL_graph_labels.txt"), 
                                     dtype=np.int64) - 1
        print(graph_labels) 
        
        
        print(adjacency_list[:, 0]) 
        print(adjacency_list[:, 1]) 
        
        num_nodes = len(node_labels)
        print(num_nodes)
        
        sparse_adjacency = sp.coo_matrix((np.ones(len(adjacency_list)), 
                                          (adjacency_list[:, 0], adjacency_list[:, 1])),
                                         shape=(num_nodes, num_nodes), dtype=np.float32)
        print("Number of nodes: ", num_nodes)
        return sparse_adjacency, node_labels, graph_indicator, graph_labels
    
    def read_data_test(self):
        data_dir = os.path.join(self.data_root, "SKEL_graph_features_test")
        print("Loading SKEL_A.txt")
        adjacency_list = np.genfromtxt(os.path.join(data_dir, "SKEL_A.txt"),
                                       dtype=np.int64, delimiter=',') - 1
        print(adjacency_list)
        
        print("Loading SKEL_node_labels.txt")
        node_labels = np.genfromtxt(os.path.join(data_dir, "SKEL_node_labels.txt"), 
                                    dtype=np.int64) - 1
        print(node_labels)    
            
        print("Loading SKEL_graph_indicator.txt")
        graph_indicator = np.genfromtxt(os.path.join(data_dir, "SKEL_graph_indicator.txt"), 
                                        dtype=np.int64) - 1
        print(graph_indicator) 
        
        print("Loading SKEL_graph_labels.txt")
        graph_labels = np.genfromtxt(os.path.join(data_dir, "SKEL_graph_labels.txt"), 
                                     dtype=np.int64) - 1
        print(graph_labels) 
        
        
        print(adjacency_list[:, 0]) 
        print(adjacency_list[:, 1]) 
        
        num_nodes = len(node_labels)
        print(num_nodes)
        
        sparse_adjacency = sp.coo_matrix((np.ones(len(adjacency_list)), 
                                          (adjacency_list[:, 0], adjacency_list[:, 1])),
                                         shape=(num_nodes, num_nodes), dtype=np.float32)
        print("Number of nodes: ", num_nodes)
        return sparse_adjacency, node_labels, graph_indicator, graph_labels
    


# ## Model defination

# ### GraphConvolution

class GraphConvolution(nn.Module):
    def __init__(self, input_dim, output_dim, use_bias=True):
        """Graph convolution: L*X*\theta

        Args:
        ----------
            input_dim: int
                Dimension of node input features.
            output_dim: int
                Dimension of output features.
            use_bias : bool, optional
                Whether to use bias.
        """
        super(GraphConvolution, self).__init__()
        self.input_dim = input_dim
        self.output_dim = output_dim
        self.use_bias = use_bias
        self.weight = nn.Parameter(torch.Tensor(input_dim, output_dim))
        if self.use_bias:
            self.bias = nn.Parameter(torch.Tensor(output_dim))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight)
        if self.use_bias:
            init.zeros_(self.bias)

    def forward(self, adjacency, input_feature):
        """The adjacency matrix is sparse, so sparse matrix multiplication is used for computation."""
        support = torch.mm(input_feature, self.weight)
        output = torch.sparse.mm(adjacency, support)
        if self.use_bias:
            output += self.bias
        return output

    def __repr__(self):
        return self.__class__.__name__ + ' ('             + str(self.input_dim) + ' -> '             + str(self.output_dim) + ')'


# ### ReadOut realization

def global_max_pool(x, graph_indicator):
    num = graph_indicator.max().item() + 1
    return torch_scatter.scatter_max(x, graph_indicator, dim=0, dim_size=num)[0]


def global_avg_pool(x, graph_indicator):
    num = graph_indicator.max().item() + 1
    return torch_scatter.scatter_mean(x, graph_indicator, dim=0, dim_size=num)


# ### Pooling layer based on self-attention mechanism

def top_rank(attention_score, graph_indicator, keep_ratio):

    """
    Based on the given attention_score, perform pooling on each graph.
    To intuitively demonstrate the pooling process, we pool each graph individually 
    and then concatenate them for the next step of computation.
    
    Arguments:
    ----------
        attention_score: torch.Tensor
            Attention scores computed using GCN, Z = GCN(A, X)
        graph_indicator: torch.Tensor
            Indicates which graph each node belongs to
        keep_ratio: float
            The ratio of nodes to retain, the number of nodes retained is int(N * keep_ratio)
    """

    graph_id_list = list(set(graph_indicator.cpu().numpy()))
    mask = attention_score.new_empty((0,), dtype=torch.bool)
    for graph_id in graph_id_list:
        graph_attn_score = attention_score[graph_indicator == graph_id]
        graph_node_num = len(graph_attn_score)
        graph_mask = attention_score.new_zeros((graph_node_num,),
                                                dtype=torch.bool)
        keep_graph_node_num = int(keep_ratio * graph_node_num)
        _, sorted_index = graph_attn_score.sort(descending=True)
        graph_mask[sorted_index[:keep_graph_node_num]] = True
        mask = torch.cat((mask, graph_mask))
    
    return mask

def filter_adjacency(adjacency, mask):

    """Update the graph structure based on the mask.
    
    Args:
        adjacency: torch.sparse.FloatTensor, adjacency matrix before pooling.
        mask: torch.Tensor(dtype=torch.bool), node mask vector.
    
    Returns:
        torch.sparse.FloatTensor, normalized adjacency matrix after pooling.
    """

    device = adjacency.device
    mask = mask.cpu().numpy()
    indices = adjacency.coalesce().indices().cpu().numpy()
    num_nodes = adjacency.size(0)
    row, col = indices
    maskout_self_loop = row != col
    row = row[maskout_self_loop]
    col = col[maskout_self_loop]
    sparse_adjacency = sp.csr_matrix((np.ones(len(row)), (row, col)),
                                     shape=(num_nodes, num_nodes), dtype=np.float32)
    filtered_adjacency = sparse_adjacency[mask, :][:, mask]
    return normalization(filtered_adjacency).to(device)

class SelfAttentionPooling(nn.Module):
    def __init__(self, input_dim, keep_ratio, activation=torch.tanh):
        super(SelfAttentionPooling, self).__init__()
        self.input_dim = input_dim
        self.keep_ratio = keep_ratio
        self.activation = activation
        self.attn_gcn = GraphConvolution(input_dim, 1)
    
    def forward(self, adjacency, input_feature, graph_indicator):
        attn_score = self.attn_gcn(adjacency, input_feature).squeeze()
        attn_score = self.activation(attn_score)
        
        mask = top_rank(attn_score, graph_indicator, self.keep_ratio)
        hidden = input_feature[mask] * attn_score[mask].view(-1, 1)
        mask_graph_indicator = graph_indicator[mask]
        mask_adjacency = filter_adjacency(adjacency, mask)
        return hidden, mask_graph_indicator, mask_adjacency


# ### Model 1：SAGPool Global Model

class ModelA(nn.Module):
    def __init__(self, input_dim, hidden_dim, num_classes=2):
    
    """Graph classification model structure A
    
    Args:
    ----
        input_dim: int, Dimension of input features
        hidden_dim: int, Number of units in the hidden layer
        num_classes: int, Number of classification categories (default: 2)
    """
        super(ModelA, self).__init__()
        self.input_dim = input_dim
        self.hidden_dim = hidden_dim
        self.num_classes = num_classes
        
        self.gcn1 = GraphConvolution(input_dim, hidden_dim)
        self.gcn2 = GraphConvolution(hidden_dim, hidden_dim)
        self.gcn3 = GraphConvolution(hidden_dim, hidden_dim)
        self.pool = SelfAttentionPooling(hidden_dim * 3, 0.5)
        self.fc1 = nn.Linear(hidden_dim * 3 * 2, hidden_dim)
        self.fc2 = nn.Linear(hidden_dim, hidden_dim // 2)
        self.fc3 = nn.Linear(hidden_dim // 2, num_classes)
        

    def forward(self, adjacency, input_feature, graph_indicator):
        gcn1 = F.relu(self.gcn1(adjacency, input_feature))
        gcn2 = F.relu(self.gcn2(adjacency, gcn1))
        gcn3 = F.relu(self.gcn3(adjacency, gcn2))
        
        gcn_feature = torch.cat((gcn1, gcn2, gcn3), dim=1)
        pool, pool_graph_indicator, pool_adjacency = self.pool(adjacency, gcn_feature,
                                                               graph_indicator)
        
        readout = torch.cat((global_avg_pool(pool, pool_graph_indicator),
                             global_max_pool(pool, pool_graph_indicator)), dim=1)
        
        fc1 = F.relu(self.fc1(readout))
        fc2 = F.relu(self.fc2(fc1))
        logits = self.fc3(fc2)
        
        return logits


# ### Model 2：SAGPool Hierarchical Model

class ModelB(nn.Module):
    def __init__(self, input_dim, hidden_dim, num_classes=2):
    
        """Graph classification model structure
        
        Args:
        -----
            input_dim: int, Dimension of input features
            hidden_dim: int, Number of units in the hidden layer
            num_classes: int, Number of classification categories (default: 2)
        """

        super(ModelB, self).__init__()
        self.input_dim = input_dim
        self.hidden_dim = hidden_dim
        self.num_classes = num_classes
        
        self.gcn1 = GraphConvolution(input_dim, hidden_dim)
        self.pool1 = SelfAttentionPooling(hidden_dim, 0.5)
        self.gcn2 = GraphConvolution(hidden_dim, hidden_dim)
        self.pool2 = SelfAttentionPooling(hidden_dim, 0.5)
        self.gcn3 = GraphConvolution(hidden_dim, hidden_dim)
        self.pool3 = SelfAttentionPooling(hidden_dim, 0.5)
        
        self.mlp = nn.Sequential(
            nn.Linear(hidden_dim * 2, hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, hidden_dim // 2),
            nn.ReLU(), 
            nn.Linear(hidden_dim // 2, num_classes))
    
    def forward(self, adjacency, input_feature, graph_indicator):
        gcn1 = F.relu(self.gcn1(adjacency, input_feature))
        pool1, pool1_graph_indicator, pool1_adjacency = self.pool1(adjacency, gcn1, graph_indicator)
        global_pool1 = torch.cat(
            [global_avg_pool(pool1, pool1_graph_indicator),
             global_max_pool(pool1, pool1_graph_indicator)],
            dim=1)
        
        gcn2 = F.relu(self.gcn2(pool1_adjacency, pool1))
        pool2, pool2_graph_indicator, pool2_adjacency = self.pool2(pool1_adjacency, gcn2, pool1_graph_indicator)
        global_pool2 = torch.cat(
            [global_avg_pool(pool2, pool2_graph_indicator),
             global_max_pool(pool2, pool2_graph_indicator)],
            dim=1)

        gcn3 = F.relu(self.gcn3(pool2_adjacency, pool2))
        pool3, pool3_graph_indicator, pool3_adjacency = self.pool3(pool2_adjacency, gcn3, pool2_graph_indicator)
        global_pool3 = torch.cat(
            [global_avg_pool(pool3, pool3_graph_indicator),
             global_max_pool(pool3, pool3_graph_indicator)],
            dim=1)
        
        readout = global_pool1 + global_pool2 + global_pool3
        
        logits = self.mlp(readout)
        return logits

def main():
    dataset = RCCDataset()

    # Model input data preparation
    DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
    adjacency = dataset.sparse_adjacency_train
    normalize_adjacency = normalization(adjacency).to(DEVICE)
    node_labels = tensor_from_numpy(dataset.node_labels_train, DEVICE)
    node_features = F.one_hot(node_labels, node_labels.max().item() + 1).float()
    graph_indicator = tensor_from_numpy(dataset.graph_indicator_train, DEVICE)
    #graph_labels = tensor_from_numpy(dataset.graph_labels, DEVICE)
    train_index = tensor_from_numpy(dataset.train_index, DEVICE)
    test_index = tensor_from_numpy(dataset.test_index, DEVICE)
    train_label = tensor_from_numpy(dataset.train_label, DEVICE)
    test_label = tensor_from_numpy(dataset.test_label, DEVICE)

    # Hyperparameter settings
    INPUT_DIM = node_features.size(1)
    NUM_CLASSES = 2
    EPOCHS = 30    # @param {type: "integer"}
    HIDDEN_DIM =    32# @param {type: "integer"}
    LEARNING_RATE = 0.01 # @param
    WEIGHT_DECAY = 0.0001 # @param

    # Model initialization
    model_g = ModelA(INPUT_DIM, HIDDEN_DIM, NUM_CLASSES).to(DEVICE)
    model_h = ModelB(INPUT_DIM, HIDDEN_DIM, NUM_CLASSES).to(DEVICE)

    model = model_g #@param ['model_g', 'model_h'] {type: 'raw'}

    criterion = nn.CrossEntropyLoss().to(DEVICE)
    optimizer = optim.Adam(model.parameters(), LEARNING_RATE, weight_decay=WEIGHT_DECAY)

    model.train()
    for epoch in range(EPOCHS):
        logits = model(normalize_adjacency, node_features, graph_indicator)
        loss = criterion(logits[train_index], train_label)  # Calculate loss only on training data
        optimizer.zero_grad()
        loss.backward()  # Backpropagation computes gradients of parameters
        optimizer.step()  # Gradient updates using optimization methods
        train_acc = torch.eq(
            logits[train_index].max(1)[1], train_label).float().mean()
        print("Epoch {:03d}: Loss {:.4f}, TrainAcc {:.4}".format(
            epoch, loss.item(), train_acc.item()))
            
    # Model input data preparation
    DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
    adjacency_test = dataset.sparse_adjacency_test
    normalize_adjacency_test = normalization(adjacency_test).to(DEVICE)
    node_labels_test = tensor_from_numpy(dataset.node_labels_test, DEVICE)
    node_features_test = F.one_hot(node_labels_test, node_labels_test.max().item() + 1).float()
    graph_indicator_test = tensor_from_numpy(dataset.graph_indicator_test, DEVICE)

    model.eval()
    with torch.no_grad():
        logits = model(normalize_adjacency_test, node_features_test, graph_indicator_test)
        test_logits = logits[test_index]
        test_acc = torch.eq(
            test_logits.max(1)[1], test_label
        ).float().mean()
        
    print("Test accuracy for Model A:", test_acc.item())

    model = model_h

    criterion = nn.CrossEntropyLoss().to(DEVICE)
    optimizer = optim.Adam(model.parameters(), LEARNING_RATE, weight_decay=WEIGHT_DECAY)

    model.train()
    for epoch in range(EPOCHS):
        logits = model(normalize_adjacency, node_features, graph_indicator)
        loss = criterion(logits[train_index], train_label)  # Calculate loss only on training data
        optimizer.zero_grad()
        loss.backward()  # Backpropagation computes gradients of parameters
        optimizer.step()  # Gradient updates using optimization methods
        train_acc = torch.eq(
            logits[train_index].max(1)[1], train_label).float().mean()
        print("Epoch {:03d}: Loss {:.4f}, TrainAcc {:.4}".format(
            epoch, loss.item(), train_acc.item()))

    # Model input data preparation
    DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
    adjacency_test = dataset.sparse_adjacency_test
    normalize_adjacency_test = normalization(adjacency_test).to(DEVICE)
    node_labels_test = tensor_from_numpy(dataset.node_labels_test, DEVICE)
    node_features_test = F.one_hot(node_labels_test, node_labels_test.max().item() + 1).float()
    graph_indicator_test = tensor_from_numpy(dataset.graph_indicator_test, DEVICE)

    model.eval()
    with torch.no_grad():
        logits = model(normalize_adjacency_test, node_features_test, graph_indicator_test)
        test_logits = logits[test_index]
        test_acc = torch.eq(
            test_logits.max(1)[1], test_label
        ).float().mean()

    print("Test accuracy for Model B:", test_acc.item())

if __name__ == "__main__":
    main()
