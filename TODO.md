# TODO 

### 2017-09-11

*Current Status*

So far the package can query from a corpus of hdf files for a one dimensional 
piece of the model run. 

*Tasks* 

- [] currently there is a small hack to make the 1d corpus work. This is because it uses the fact
that the input is of list type to iterate over it. However when reading just a single file this 
breaks, Solution needs to be implemented. 
- [] 


### 2017-09-06 
 
Current feature set is, reading a single hdf file from disk and extracting either
and 2d portion of the model using a single x, y coordinate, or extracting a 
cross section portion of the model using a cross section location. 
 
Today will work on 2d features namely:
* add multiple coordiante query for one hdf file 
* add multiple hdf file queries per one coordinate 
 
 