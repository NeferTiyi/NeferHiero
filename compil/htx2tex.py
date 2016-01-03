#!/usr/bin/env python
# -*- coding: utf-8 -*-

# this must come first
from __future__ import print_function, division

# standard library imports
from argparse import ArgumentParser
# import socket
import os
import os.path
import fileinput
import subprocess
# import glob
# import shutil
# import datetime as dt
# import numpy as np

# Application library imports
# from gencmip6_path import *


########################################
def get_arguments():
  parser = ArgumentParser()
  parser.add_argument("filehtx", help="htx file to process")
  parser.add_argument("-v", "--verbose", action="store_true",
                      help="verbose mode")

  return parser.parse_args()


########################################
if __name__ == '__main__':

  # .. Initialization ..
  # ====================
  # ... Command line arguments ...
  # ------------------------------
  args = get_arguments()
  if args.verbose:
    print(args)

  filehtx = args.filehtx

  hierodef = "/media/sf_egypto/NeferHiero/utils/HieroDef.txt"

  filehtx_base = os.path.splitext(os.path.basename(filehtx))[0]
  filehtx_ext  = os.path.splitext(os.path.basename(filehtx))[1]
  filehtx_dir  = os.path.dirname(os.path.abspath(filehtx))

  if not filehtx_ext:
    filehtx_ext = ".htx"

  if filehtx_ext != ".htx":
    print("Wrong file type, we stop")
    exit(1)

  filehtx = os.path.join(filehtx_dir, filehtx_base + filehtx_ext)

  if not os.path.isfile(filehtx):
    print("File {} not found, we stop".format(filehtx))
    exit(1)

  if args.verbose:
    print(filehtx_base, filehtx_ext, filehtx_dir)

  filehtx_full = os.path.join(
    filehtx_dir, filehtx_base + "_full" + filehtx_ext
  )

  filetex = os.path.join(
    filehtx_dir, filehtx_base + ".tex"
  )

  # with open(filein, "r") as fin:
  #   # lignes = filein.read()
  #   # print(lignes)
  #   if "%##HieroDef.txt" in fin.read():
  #     print("ok")

  if args.verbose:
    print("build {}".format(filehtx_full))
  with open(filehtx_full, "w") as fout:
    for line in fileinput.input([hierodef, filehtx]):
      # print(line.strip())
      fout.write(line)

  # # command = ["sesh", "<", filehtx_full, ">", filetex]
  # command = ["sesh", "<" + filehtx_full]
  command = "sesh < " + filehtx_full

  if args.verbose:
    print("produce {}".format(filehtx_full))
  try :
    # subprocess.call(command)
    subproc = \
      subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
  except Exception as rc :
    print("Error in sesh for {}:\n{}".format(filehtx_base, rc))
    exit(1)

  if args.verbose:
    print("save to {}".format(filetex))
  with open(filetex, "w") as ftex:
    for line in subproc.stdout :  # .read()
      ftex.write(line)

  try :
    os.remove(filehtx_full)
  except Exception as rc:
    print("Error in remove for {}:\n {}".format(filehtx_full, rc))
    exit(1)
