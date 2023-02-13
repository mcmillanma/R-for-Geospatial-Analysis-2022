library(caret)
library(randomForest)

#training sample index
trainIndex <- createDataPartition(iris$Species, p = .5, 
                                  list = FALSE,  times = 1)

#prepare training and testing samples
iris_train<-iris[trainIndex,]
iris_test<-iris[-trainIndex,]


control <- trainControl(method='cv', number=5)
#use random forest for classification
model_test <- train(as.factor(Species) ~ ., data=iris_train, method='rf', 
                    tuneLength=3, trControl = control)

pred <- predict(model_test, iris_test)
xtab <- table(pred, iris_test$Species)
confusionMatrix(xtab)

#use a mlp neural network
model_test <- train(as.factor(Species) ~ ., data=iris_train, method='mlp',
                    tuneLength=3, trControl = control)
pred <- predict(model_test, iris_test)
xtab <- table(pred, iris_test$Species)
confusionMatrix(xtab)

