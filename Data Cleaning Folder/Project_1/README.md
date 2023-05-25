# Data Cleaning Project 1
A SQL data cleaning project

## Introduction
A small SQL Data cleaning project 
Inspired and guided by [one of Alex's projects](https://github.com/AlexTheAnalyst/PortfolioProjects)

Walkthrough queries by [Alex the Analyst](https://www.youtube.com/watch?v=8rO7ztF4NtU&t=677s)

[Data Cleaning Walk-Through](https://github.com/shandarren/resume/blob/main/Data%20Cleaning%20Folder/Project_1/DATA_CLEANING.md)

## Problem Statement

In Data Analysis, the analyst must ensure that the data is 'clean' before doing any analysis.  'Dirty' data can lead to unreliable, inaccurate and/or misleading results.  Garbage in = garbage out. The following steps shall be conducted:

- Change date format
- Populate some null values in address column
- Separate full address to individual columns (Address, City, State)
- Standardize SoldAsVacant column
- Remove duplicates rows using 2 techniques: Groupby & Having Clauses; row_number()
- Remove unused columns

## Datasets used
This dataset contains one csv file named '[Nashville Housing Data for Data Cleaning](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx)'.

The initial columns and their type in the provided CSV file are:
- UniqueID : text
- ParcelID : text
-	LandUse	: text
-	PropertyAddress	: text
-	SaleDate	: date
-	SalePrice	: int
-	LegalReference	: text
-	SoldAsVacant	: text
-	OwnerName	: text
-	OwnerAddress	: text
-	Acreage	: int
-	TaxDistrict	: text
-	LandValue	: int
-	BuildingValue	: int
-	TotalValue	: int
-	YearBuilt	: int
-	Bedrooms	: int
-	FullBath	: int
-	HalfBath  : int
