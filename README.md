# AiyagariPiketty_replication
Replication files for When Aiyagari meets Piketty: Growth, Inequality and Factor Shares

To run the replication files for the empirical analysis:
1) download the repository
2) go to Statadofiles and find _master.do
3) in this do-file, change 'DIRECTORY' in the first row to match the location in your computer
4) run the do-file
  4.1) loads some packages, retrieves data using Stata's features, combines these data with manually downloaded data that are in Data\Original, saves the resulting cross-country panel data sets in Data;
  4.2) draws illustrations based on theoretical simulations;
  4.3) empirical analysis for the 1950--> sample (results in Tables and Figures, figures also open in Stata);
  4.4) empirical analysis for the 1980--> sample (results in Figures, figures also open in Stata);
  4.5) erase some of the temporary files saved along the way
  
To run the replication for the theoretical analysis: open the files in Theory\Simulations in Matlab
