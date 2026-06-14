
# turing-passthrough
just some idea spitballing on how to passthrough a turing GPU to a VM. Developed for nix channel 26.05 and has not been tested yet. 


PCLe lanes might differ from setup to setup, so adjusting the file is likely to be needed. (for example check with lspci -nnk)


Specialisations are not needed for this, it's just the format i am using right now. 


Screenshot taken from the host of # passthroughsnipped.nix

<img width="1248" height="187" alt="screenshot" src="https://github.com/user-attachments/assets/b406b3e2-aacb-4fa6-ae0b-fee558a9bb8e" />
