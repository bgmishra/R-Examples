context("bagging ensemble classifier")
test_that("bagging returns a character vector of predicted classes",{
    outcomes <- c("laying", "sitting", "standing", "walking", "walking_downstairs", "walking_upstairs")
    train <- data.frame(activity=sample(outcomes,10,replace=T),V1=rnorm(10),V2=rnorm(10),V3=rnorm(10))
    test <- data.frame(V1=rnorm(10),V2=rnorm(10),V3=rnorm(10))
    p<-bagging(activity~.,train,test,3,ntree=5,trace=F)
    expect_is(p,"character")
    expect_equal(length(p),nrow(test))
})

test_that("bagPrediction returns the class receiving the most votes in a sample with ties broken at random",{
  sample<-c("standing","standing","standing")
  expect_equal(bagPrediction(sample),"standing")
  sample<-c("standing","standing","sitting")
  expect_equal(bagPrediction(sample),"standing")
  sample<-c("standing","sitting","sitting")
  expect_equal(bagPrediction(sample),"sitting")
  sample<-c("standing","sitting","sitting","standing")
  expect_true(bagPrediction(sample) %in% c("sitting","standing"))
  sample<-c("standing","sitting","sitting","sitting")
  expect_equal(bagPrediction(sample),"sitting")
  sample<-c("standing","sitting","sitting","sitting","laying","walking downstairs")
  expect_equal(bagPrediction(sample),"sitting")
  sample<-c("a","a","a","b","b")
  expect_equal(bagPrediction(sample),"a")
})

test_that("maxVoteCount returns the max vote count for a class (or classes in case of tie)",{
  sample<-c("standing","sitting","sitting","sitting","laying","walking downstairs")
  expect_equal(maxVoteCount(sample),3)
  sample<-c("standing","standing","standing","sitting","sitting","sitting","laying","walking downstairs")
  expect_equal(maxVoteCount(sample),3)
  sample<-c("sitting","standing","standing","standing","sitting","sitting","sitting","laying","walking downstairs")
  expect_equal(maxVoteCount(sample),4)
  sample<-c("sitting","standing","laying","walking downstairs")
  expect_equal(maxVoteCount(sample),1)
})

test_that("maxClasses returns the names of the class or classes receiving the most votes in sample",{
  sample<-c("standing","sitting","sitting","sitting","laying","walking downstairs")
  expect_equal(maxClasses(sample),"sitting")
  sample<-c("standing","standing","standing","sitting","sitting","sitting","laying","walking downstairs")
  expect_equal(setdiff(maxClasses(sample),c("sitting","standing")),character(0)) 
  sample<-c("sitting","standing","standing","standing","sitting","sitting","sitting","laying","walking downstairs")
  expect_equal(maxClasses(sample),"sitting")
  sample<-c("sitting","standing","laying","walking downstairs")
  expect_equal(setdiff(maxClasses(sample),c("sitting","standing","laying","walking downstairs")),character(0))
})