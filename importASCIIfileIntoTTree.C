#include "TFile.h"
#include "TTree.h"

int importASCIIfileIntoTTree(const char *filename, const char *Dir)
{
    std::string outputFileName = std::string(Dir) + "/HIJING_LBF_test_small.root"; // name of the output ROOT file
    TFile *file = new TFile(outputFileName.c_str(),"update"); // open ROOT file named 'output.root', where TTree will be saved
    TTree *tree = new TTree("event","data from ascii file"); // make the new TTree for each event

    Long64_t nlines = tree->ReadFile(filename,"PID:px:py:pz:E"); // whatever you specify here, will be relevant when you start later reading the TTree branches
    tree->Write(); // save TTree to output file
    file->Close();
    
    
 return 0;   
} 