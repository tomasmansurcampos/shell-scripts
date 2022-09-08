#!/bin/bash
gnu_c_reference_()
{
  apt update
  apt install -y git texinfo texlive
  git clone https://git.savannah.gnu.org/git/c-intro-and-ref.git
  cd c-intro-and-ref
  mkdir c-manual
  ln Makefile c.texi cpp.texi fp.texi fdl.texi c-manual
  tar czf c-manual.tgz c-manual
  cd c-manual
  texi2pdf c.texi
  cp c.pdf $HOME
  cd ../..
  rm -rf c-intro-and-ref
  cd $HOME
}
gnu_c_reference_
