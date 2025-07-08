# Monzey's dotfiles
![Alt text](./preview.png?raw=true "Title")

## From a fresh install of nixos

```bash
  git clone https://github.com/monzey/bonsly.git && cd bonsly
  chmod a+x setup
  ./setup
```

If you want to update your system, you just have to do 
```bash
  update -hsr
```

don't forget to add your private ssh key in `home-manager/configs/ssh/id_ed25519` and to run `update` right after

That's it !
