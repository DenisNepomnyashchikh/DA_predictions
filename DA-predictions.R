library(mlbench)
library(rpart)
library(randomForest)
library(mlr)

#Dividing train dataset to mytrain and mytest
divide <- function(data){
  someindex <- sample(1:nrow(data), 0.2*nrow(data))
  mytest <<- data[someindex,]
  mytrain <<- data[-someindex,]
  colnames(mytrain)[11] <<- "Result"
  colnames(train)[11] <<- "Result"
}

#Plotting optimization grid
plot.grid <- function(data){
  opt.grid = as.data.frame(data)
  library(ggplot2)
  g = ggplot(opt.grid, aes(x = C, y = sigma, fill = mse.test.mean, label = round(mse.test.mean, 2)))
  g + geom_tile() + geom_text(color = "white")
}

#Fitting models with linear model, classification tree and randomforest
fit.func <- function(){
  set.seed(123123)
  fit.lm = lm(Result ~ ., data = train)
  fit.tree = rpart(Result ~ ., data = train)
  fit.ranF = randomForest(Result ~ ., data = train, ntree = 1000)
  m1 <<- mean((fit.lm$residuals)^2)
  
  pred.tree = predict(fit.tree, newdata = train[,-11], type = "vector")
  m2 <<- mean((train[11] - pred.tree)^2)
  
  pred.ranF = predict(fit.ranF, newdata = train[,1:10])
  m3 <<- mean((train[11] - pred.ranF)^2)
}

#SVM Application
svm.func <- function(vtrain, vtest){
  set.seed(123123)
  task = makeRegrTask(data = vtrain, target = "Result")
  lrn.svm = makeLearner("regr.ksvm")
  mod = train(lrn.svm, task)
  newdata.pred = predict(mod, newdata = vtest[,1:10])
  pred.svm <- as.data.frame(newdata.pred)
  m4 <<- mean((vtest[11] - pred.svm)^2)
}

#Tuning optimization grid with resampling
svm.tun1 <- function(vtrain, vtest){
  task = makeRegrTask(data = vtrain, target = "Result")
  ps = makeParamSet(
    makeDiscreteParam("C", values = 2^(-2:2)),
    makeDiscreteParam("sigma", values = 2^(-2:2))
  )
  ctrl = makeTuneControlGrid()
  #rdesc = makeResampleDesc("CV", iters = 3L)
  rdesc = makeResampleDesc("Holdout")
  res = tuneParams("regr.ksvm", task = task, resampling = rdesc, par.set = ps,
                   control = ctrl)
  lrn.tun1 = setHyperPars(makeLearner("regr.ksvm"), par.vals = res$x)
  m = train(lrn.tun1, task)
  newdata.pred1 = predict(m, newdata = vtest[,1:10])
  pred.svm1 <- as.data.frame(newdata.pred1)
  m5 <<- mean((vtest[11] - pred.svm1$response)^2)
  plot.grid(res$opt.path)
}

#Tuning SVM with trafo functions and resampling
svm.tun2 <- function(vtrain, vtest){
  set.seed(123123)
  task = makeRegrTask(data = vtrain, target = "Result")
  ps = makeParamSet(
    makeNumericParam("C", lower = -12, upper = 12, trafo = function(x) 2^x),
    makeNumericParam("sigma", lower = -12, upper = 12, trafo = function(x) 2^x)
  )
  ctrl = makeTuneControlGrid()
  rdesc = makeResampleDesc("CV", iters = 5L)
  #rdesc = makeResampleDesc("Holdout")
  #rdesc = makeResampleDesc(method = "Bootstrap", iters = 50, predict = "both")
  res = tuneParams("regr.ksvm", task = task, resampling = rdesc, par.set = ps,
                   control = ctrl)
  lrn.tun2 = setHyperPars(makeLearner("regr.ksvm"), par.vals = res$x)
  m = train(lrn.tun2, task)
  newdata.pred1 = predict(m, newdata = vtest[,1:10])
  pred.svm <<- as.data.frame(newdata.pred1)
  m6 <<- mean((vtest[11] - pred.svm$response)^2)
  plot.grid(res$opt.path)
  fv <<- generateFilterValuesData(task, method = "information.gain")
  plotLearnerPrediction(lrn.tun2, features = c("Horse_Power", "Engine_Size"), task = task)
}



#A
load("data_A.RData")
train <- data.frame(train, stringsAsFactors = F)
#Modify first three variable as factor
train$Manufacturer <- as.factor(train$Manufacturer)
train$Model <- as.factor(train$Model)
train$Vehicle_Class <- as.factor(train$Vehicle_Class)

#Divide train
divide(train)

#Fitting models
fit.func()

#SVM implementation
svm.func(mytrain, mytest)

#SVM with tuning
svm.tun1(mytrain, mytest)
svm.tun2(mytrain, mytest)

#Comparison MSE
m.data <- rbind(m1, m2, m3, m4, m5, m6)
colnames(m.data) <- "MSE"
rownames(m.data) <- c('lm', 'rpart', 'ranf', 'svm', 'svm.tun1', 'svm.tun2')
df <- as.data.frame(m.data)
ggplot(data=df) +
  aes(x = reorder(rownames(df), -MSE), y = MSE) +
  geom_bar(stat="identity", fill="green")


#Prediction
svm.tun2(train, test)
write.table(pred.svm, file = "Pred_A.txt",row.names=FALSE, col.names=FALSE, sep=';')



#B
load("data_B.RData")
train <- data.frame(train, stringsAsFactors = F)

imp = impute(train, classes = list(numeric = imputeMean(), factor = imputeMode()),
             dummy.classes = "integer")
train <- imp$data

divide(train)
fit.func()
svm.func(mytrain, mytest)

svm.tun1(mytrain, mytest)
svm.tun2(mytrain, mytest)

imp = impute(test, classes = list(numeric = imputeMean(), factor = imputeMode()),
             dummy.classes = "integer")
test <- imp$data


svm.tun2(train, test)
write.table(pred.svm, file = "Pred_B.txt",row.names=FALSE, col.names=FALSE, sep=';')

#C
load("data_C.RData")
train <- data.frame(train, stringsAsFactors = F)


divide(train)
fit.func()
svm.func(mytrain, mytest)
svm.tun1(mytrain, mytest)
svm.tun2(mytrain, mytest)
svm.tun2(train, test)
write.table(pred.svm, file = "Pred_C.txt",row.names=FALSE, col.names=FALSE, sep=';')


#D
load("data_D.RData")
train <- data.frame(train, stringsAsFactors = F)


divide(train)
fit.func()
svm.func(mytrain, mytest)
svm.tun1(mytrain, mytest)
svm.tun2(mytrain, mytest)
svm.tun2(train, test)
write.table(pred.svm, file = "Pred_D.txt",row.names=FALSE, col.names=FALSE, sep=';')