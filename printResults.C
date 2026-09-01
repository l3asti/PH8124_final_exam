#include <TFile.h>
#include <TH1F.h>
#include <TCanvas.h>
#include <TError.h>
#include <iostream>
#include <vector>

int printResults(const char *filename, const char *TopDir)
{
    gErrorIgnoreLevel = kError;  // ignore ROOT warnings but not errors

    TFile *file = TFile::Open(filename, "READ"); // open the ROOT file for reading
    if(!file) //check if file was oppend successfully
    {
        std::cerr << "Error opening file: " << filename << std::endl;
        return 1; // return an error code
    }

    TFile *outputFile = TFile::Open(Form("%s/ResultHist.root", TopDir), "RECREATE"); // open the ROOT file for writing histograms

    static std::vector<TH1F *> h1(3); // vector for the 3 histograms
    h1[0] = dynamic_cast<TH1F*>(file->Get("h1_pi")); // retrieve the histogram for pions
    h1[1] = dynamic_cast<TH1F*>(file->Get("h1_K")); // retrieve the histogram for kaons
    h1[2] = dynamic_cast<TH1F*>(file->Get("h1_p")); // retrieve the histogram for protons

    if(!h1[0] || !h1[1] || !h1[2]) // check if all histograms were retrieved
    {
        std::cerr << "Error retrieving histograms from file: " << filename << std::endl;
        return 1; // return an error code
    }
    

    TCanvas *c = new TCanvas("c1", "p_{T} Distributions", 1800, 600);  // create a canvas for drawing histograms
    Int_t nHist = h1.size();
    c->Divide(nHist, 1); // divide the canvas into nHist pads
    for(Int_t i = 0; i < nHist; ++i) // loop over all histograms
    {
        
        c->cd(i+1); // go to the i-th pad
        gPad->SetLeftMargin(0.15); // increase left margin to show y-axis label
        h1[i]->Draw(); // draw the histogram
        std::cout << h1[i]->GetMean() << std::endl; // print the mean of the histogram to the console
    }

    outputFile->cd(); // go to the output file
    c->Write(); // write the canvas to the file, overwriting if it exists
    std::vector<std::string> extentions = {".png", ".eps", ".pdf", ".C"}; // list of file extensions to save the canvas
    for(int i = 0; i < extentions.size(); ++i)
    {
        c->SaveAs(Form("%s/ResultHist%s", TopDir, extentions[i].c_str())); // save the canvas in different formats
    }

    outputFile->Close(); // close the output file
    file->Close(); // close the file


    return 0; // return success
}