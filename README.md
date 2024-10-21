# **ADULT CENSUS DATASET WITH GAUSSIAN NAIVE BAYES**

The project named Adult Census with Gaussian Naive Bayes is based on
implementation of the popular Gaussian Naive Bayes classification
technique.

## **DATASET DESCRIPTION**

The dataset is originally created by Ronny Kohavi and Barry Becker in
1994. The dataset contains data of people aging from 17-99 and hours per
week at least greater than 0. The dataset's target feature is to find
out whether a persons yearly income is over \$50k.

*Features found in the dataset*

1.Age - age of person

2.Work class - Private, Stage-gov, Federal-gov, Self-emp-not-inc

3.fnlwgt - final weight

4.Education - HS-grad, Some-college, Doctorate, etc.

5.education.num - Assigning education categories into numeric values
from 1-16

6.marital.status - Widowed, Divorced, Separated, Married-civ-spouse

7.Occupation - Various occupations such as Prof-specialty, Adm-clerical,
Exec-managerial, etc.

8.Relationship - Unmarried, Not-in-family, Own-child, etc.

9.Race - White, Black, Asian-pac-Islander, etc.

10.Sex - Male and Female

This is the dataset link from kaeggle:[Adult Census
Dataset](https://www.kaggle.com/datasets/uciml/adult-census-income)

## **IMPLEMENTATION TECHNIQUE**

The dataset was pre-processed before implementing Gaussian naive Bayes
classifier. Missing value handling, conversion of categorical columns to
numeric, splitting data for training and testing purpose, selection of
numeric columns and calculation of means and standard deviations.
Defining Gaussian probability density function, implementation of simple
Gaussian naive Bayes, evaluation of predictions and extraction of
confusion matrix and performance metrics can be found in this R script.
