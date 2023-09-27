def run_training_range(classifier, scoring_function, n_samples, X_train, y_train, X_test, y_test, **kwargs):
    train_loss = []
    test_loss = []
    for sub_sample in n_samples:
        classifier.fit(X_train[:sub_sample], y_train[:sub_sample])
        train_pred = classifier.predict(X_train)
        test_pred = classifier.predict(X_test)
        
        train_loss.append(scoring_function(train_pred, y_train, **kwargs))
        test_loss.append(scoring_function(test_pred, y_test, **kwargs))
    
    return [train_loss, test_loss]

def compare_classifiers(classifier_dict, scoring_function, X_test, y_test, **kwargs):
    performance = {}
    for lbl, clf in zip(classifier_dict.keys(), classifier_dict.values()):
        performance[lbl] = scoring_function(y_test, clf.predict(X_test), **kwargs)
        
    return performance