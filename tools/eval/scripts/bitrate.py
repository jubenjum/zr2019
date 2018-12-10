from __future__ import print_function, division

import read_zrsc2019 
import argparse
import math
import sys

def entropy_symbols(nbr_lines, d_symbol2occ):
    """Calculate the entropy for all different symbols in the file
    
    Argument(s);
    nbr_lines : number of symbols in the file (number of lines)
    d_symbol2occ : contains all different type of symbols and how many
    time they appear in the file
    
    Returns :
    ent_s : the entropy for all symbols
    """
    ent_s = 0
    for s in d_symbol2occ.keys():
        # Number of times symbol s was observed in the file
        s_occ = d_symbol2occ[s]
        # Probability of apparition of symbol s
        p_s = s_occ/nbr_lines
        if p_s > 0:
            ent_s += -(p_s* math.log(p_s, 2))
    return ent_s

def bitrate(sym,  nbr_lines, total_duration):
    """Calculate bitrate
    
    Argument(s);
    nbr_lines : number of duration in the file (e.g number of lines)
    total_duration : total time duration of file

    Returns :
    bitrate : the bitrate for encoding given file as :
    B = (N/D) *  (H(s))
    Where N is the number of segmentation in the document (lines)
    D is the totel length of the audio file (sum of all durations)
    H(s) is the entropy for all symbols s that appears in the document
    """
    bitrate = None
    if len(sym) > 0:
        bitrate = nbr_lines*entropy_symbols(nbr_lines, sym)/total_duration
    return bitrate

if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument('--dont-complain-about-missing-files', action="store_true")
    argparser.add_argument('folder', help="Name of the submission folder")
    argparser.add_argument('file_list', help="Name of duration file")
    args = argparser.parse_args()

    try:
        symbol_counts, n_lines, total_duration = \
            read_zrsc2019.read_all(args.file_list,
                                   args.folder,
                                   not args.dont_complain_about_missing_files,
                                   log=False)
        print("Read " + str(len(symbol_counts)) + " distinct symbols")
        print("Total number of lines: " + str(len(n_lines)))
        print("Total duration: " + str(len(total_duration)))
        print("Estimated bitrate (bits/s): " +
              str(bitrate(symbol_counts, n_lines, total_duration)))
    except read_zrsc2019.ReadZrsc2019Exception as e:
        sys.exit("Error reading embedding file (run validation script!): " + str(e))
    except IOError as e:
        sys.exit("Error opening file list " + args.file_list + ": " + str(e))




