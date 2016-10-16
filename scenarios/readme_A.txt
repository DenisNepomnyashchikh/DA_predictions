##  Package Description

In the following section we want to describe the features, as well as the target value of our `rcars` data
generator:

## Features

* **`Manufacturer`**  
  `chr vector` containing n manufacturer names (one for each item). Typically there will be duplicates, multiple models
  can exist for one manufacturer/models can exist multiple times.

* **`Model`**  
  `chr vector` containing n model names (one for each item). Typically there will be duplicates as multiple instances of
  a model can exist. It is ensured that all instances of a *model* will be associated to the same *manufacturer* and
  *vehicle class*.

* **`Vehicle_Class`**  
  `chr vector` containing n vehicle class names (one for each item). Typically there will be duplicates as multiple
  models can exist for a given *vehicle class*.

* **`Year_of_Construction`**  
  `int vector` containing n year values in the format `YYYY` (one for each item).

* **`Number_of_Accidents`**  
  `int vector` containing n accident numbers (one for each item).

* **`Number_of_prev_Owners`**  
  `int vector` containing n previous owner numbers (one for each item).

* **`Mileage`**  
  `num vector` containing the mileages of the different cars (one for each item).

* **`Engine_Size`**  
  `int vector` containing the engine sizes in ccm of the different cars (one for each item).

* **`Cylinders`**  
  `num vector` containing the cylinder count of the different cars (one for each item).

* **`Horse_Power`**  
  `num vector` containing the horse power of the different cars (one for each item).


### Target Value

The target value of our dataset is the `fuel_consumption` which provides information about the consumption of the
specified car.
