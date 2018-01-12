import numpy as np


def irsa_table(filename, ra, dec, name):
    fp = open(filename, "w")
    header = """|   ra           |         dec    |      name  |
|   double       |     double     |   int      |
|   deg          |    deg         |            |
|   null         |    null        |  null      |\n"""
    line = "  {ra:14.7f}   {dec:14.7f}   {name:10}  \n"
    fp.write(header)
    for indx in np.arange(len(ra)):
        out = line.format(ra=ra[indx], dec=dec[indx], name=str(name[indx]))
        fp.write(out)
    fp.close()
