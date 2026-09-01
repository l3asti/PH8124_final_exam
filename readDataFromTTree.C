#include <TFile.h>
#include <TTree.h>
#include <TH1F.h>
#include <TError.h>
#include <Math/GenVector/PxPyPzE4D.h>
#include <iostream>

int readDataFromTTree(const char *filename, const char *TopDir)
{
    gErrorIgnoreLevel = kError;
    TFile *outputFile = TFile::Open(Form("%s/AnalysisResults.root",TopDir),"update"); // open the ROOT file for reading and writing
    if(!outputFile) // check if the file was opened successfully
    {
        std::cerr << "Error opening file: " << filename << std::endl;
        return 1; // return an error code
    }

    // Open histograms if they exist, otherwise create new ones
    static std::vector<TH1F *> h1(3); // static vector for the 3 histograms

    h1[0] = dynamic_cast<TH1F*>(outputFile->Get("h1_pi")); // retrieve the histogram for pions
    if(!h1[0]) h1[0] = new TH1F("h1_pi", "p_{T} distribution of pions;p_{T} [GeV/c];Counts", 100, 0., 5.); // histogram for pions

    h1[1] = dynamic_cast<TH1F*>(outputFile->Get("h1_K")); // retrieve the histogram for kaons
    if(!h1[1]) h1[1] = new TH1F("h1_K", "p_{T} distribution of kaons;p_{T} [GeV/c];Counts", 100, 0., 5.); // histogram for kaons

    h1[2] = dynamic_cast<TH1F*>(outputFile->Get("h1_p")); // retrieve the histogram for protons
    if(!h1[2]) h1[2] = new TH1F("h1_p", "p_{T} distribution of protons;p_{T} [GeV/c];Counts", 100, 0., 5.); // histogram for protons
    

 TFile *file = new TFile(filename,"update"); // there are a few TTree's in this file, each corresponds to different event

 TList *lofk = file->GetListOfKeys(); // standard ROOT stuff, to read all entries in the ROOT file

 for(Int_t i=0; i<lofk->GetEntries(); i++)
 {
  TTree *tree = (TTree*) file->Get(Form("%s;%d",lofk->At(i)->GetName(),i+1)); // works if TTrees in ROOT file are named 'event;1', 'event;2'. Otherwise, adapt for your case

  if(!tree || strcmp(tree->ClassName(),"TTree")) // make sure the pointer is valid, and it points to TTree
  {
   std::cout<<Form("%s is not TTree!",lofk->At(i)->GetName())<<std::endl; 
   continue;
  }

  //tree->Print();  //from this printout, you can for instance inspect the names of the TTree's branches

  std::cout<<Form("Accessing TTree named: %s",tree->GetName())<<": "<<tree<<std::endl;
  Int_t nParticles = (Int_t)tree->GetEntries(); // number of particles
  std::cout<<Form("=> It has %d particles.",nParticles)<<std::endl;

  // Attach local variables to branches:
  Float_t PID = 0.;
  Float_t px = 0., py = 0., pz = 0., E = 0.;
  tree->SetBranchAddress("PID",&PID); // that the name of this branch is px, you can inspect from tree->Print() above, and so on
  tree->SetBranchAddress("px",&px); 
  tree->SetBranchAddress("py",&py);
  tree->SetBranchAddress("pz",&pz);
  tree->SetBranchAddress("E",&E);

  for(Int_t p = 0; p < nParticles; p++) // loop over all particles in a current TTree
  {
    tree->GetEntry(p);

    // use the ROOT::Math::PxPyPzE4D Lorentzvectors to calculate the transverse momentum insted of std::sqrt(px*px + py*py) to avoid mistakes and #include <cmath>
    ROOT::Math::PxPyPzE4D<double> particle(px,py,pz,E); // make a Lorentz vector for the current particle
    Float_t pt = particle.Pt(); // get the transverse momentum of the particle
    switch (abs(int(PID))) // sort for pi+, K+, p, and ist antipartical (not neutral version e.g. pi0, K0, n) and fill the corresponding histogram
    {
        case 211: // pion
            h1[0]->Fill(pt); // fill the histogram for pions
            break;
        case 321: // kaon
            h1[1]->Fill(pt); // fill the histogram for kaons
            break;
        case 2212: // proton
            h1[2]->Fill(pt); // fill the histogram for protons
            break;
    }
  }  

  outputFile->cd(); // make sure we are in the right directory to write histograms

  

  std::cout<<"Done with this event, marching on...\n"<<std::endl;  

 }

 // write all the histograms while overiting old date
  for (int i = 0; i < h1.size(); ++i)
  {
    h1[i]->Write(h1[i]->GetName(),TObject::kSingleKey+TObject::kWriteDelete);
  }

 file->Close(); 
 outputFile->Close();

 return 0;
}