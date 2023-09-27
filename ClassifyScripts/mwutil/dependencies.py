# make sure dependencies are satisfied (py2.7, scipy & sklean 0.16.x is assumed)
# this should only be run once (if needed) to cover the ANN dependencies

import pip

def install(package):
    pip.main(['install', package])

install("-r https://raw.githubusercontent.com/dnouri/nolearn/master/requirements.txt")
install("git+https://github.com/dnouri/nolearn.git@master#egg=nolearn==0.7.git")
install("-r https://raw.githubusercontent.com/Lasagne/Lasagne/master/requirements.txt")
install("https://github.com/Lasagne/Lasagne/archive/master.zip")