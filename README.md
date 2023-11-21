# GAI_BBC_example
Demonstration of the adaptation of the GAI to Big Butterfly Count data to adjust for phenology.

Please see the associated paper for details: Dennis, E.B., Diana, A., Matechou, E. and Morgan, B.J.T (2023) Efficient statistical inference methods for assessing changes in species' populations using citizen science data. Under submission.

The following data files are provided:

BBC_sampling_period_dates.csv - lists the start and end dates for BBC sampling each year

x_BBC_data_2011_to_2022.csv - BBC counts for 2011-2022 for species (x) where locations are given at the 1km scale that we use to define a site

x_flightperiods.csv - daily flight period estimates for a given species (x) for 2011-2022, producing from fitting a spline GAI to UKBMS data on the daily scale

x_UKBMS_GAI_abundance_index.csv - abundance index for species (x) estimated from UKBMS data for 2011-2022, where TRMOBS_UKBMS is the abundance index on the log10 scale with a mean value of 2.

We are very grateful to all of the people who have contributed to the Big Butterfly Count. The UKBMS is organised and funded by Butterfly Conservation, the British Trust for Ornithology (BTO), and the Joint Nature Conservation Committee (JNCC). The UKBMS is indebted to all volunteers who contribute data to the scheme.
