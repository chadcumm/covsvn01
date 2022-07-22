# Client-Scripts
This project contains any custom CCL scripts written for clients.
## rfm_upd_referrals_to_status.prg
* Written For: ICT_UT
* Code Level: 2018.01.06
* Delivery Date: July 2019

This script takes 3 inputs: The output location of the prompts, the backend file location of a .csv file containing referral IDs, and a CDF meaning from Referral Status codeset 4002978.  The script will read in all referral IDs from the CSV.  It will then update the status of each referral to the provided Referral Status and create a REFERRAL_HIST row.

Synatax Example:
* execute rfm_upd_referral_to_status "MINE", "/home/ct016698/referral_test.csv", "REJECTED" go

## rfm_upd_referrals_to_stat_180111.prg
* Written For: CHS_TN
* Code Level: 2018.01.11
* Delivery Date: August 2021

This script takes 3 inputs: The output location of the prompts, the backend file location of a .csv file containing referral IDs, and a CDF meaning from Referral Status codeset 4002978.  The script will read in all referral IDs from the CSV.  It will then update the status of each referral to the provided Referral Status and create a REFERRAL_HIST row.  This script will also set the REFERRAL_SUBSTATUS_CD to 0.  It includes all fields on the REFERRAL_HIST table as of 2018.01.11

Synatax Example:
* execute rfm_upd_referrals_to_stat_180111 "MINE", "/home/ct016698/referral_test.csv", "REJECTED" go

## rfm_upd_referrals_to_stat_1805.prg
* Written For: LIFE_TN
* Code Level: 2018.05
* Delivery Date: January 2021

This script takes 3 inputs: The output location of the prompts, the backend file location of a .csv file containing referral IDs, and a CDF meaning from Referral Status codeset 4002978.  The script will read in all referral IDs from the CSV.  It will then update the status of each referral to the provided Referral Status and create a REFERRAL_HIST row.  This script will also set the REFERRAL_SUBSTATUS_CD to 0.  It includes all fields on the REFERRAL_HIST table as of 2018.05

Synatax Example:
* execute rfm_upd_referrals_to_stat_1805 "MINE", "/home/ct016698/referral_test.csv", "REJECTED" go