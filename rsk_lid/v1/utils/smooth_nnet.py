#!/usr/bin/env python

# Copyright 2017       Florian Metze     (Carnegie Mellon University)

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
# WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
# MERCHANTABLITY OR NON-INFRINGEMENT.
# See the Apache 2 License for the specific language governing permissions and
# limitations under the License.

import sys, re, os, numpy, pipes, itertools, kaldi_io

def parse_arguments(arg_elements):
    args = {}
    arg_num = len(arg_elements) / 2
    for i in xrange(arg_num):
        key = arg_elements[2*i].replace("--","").replace("-", "_");
        args[key] = arg_elements[2*i+1]
    return args


if __name__ == '__main__':

    """
    Python script to smooth the output of a CTC network. Parameters:
    ------------------
    --frames : int
        How many frames to average temporally.
        Optional.

    """


    # parse arguments
    arg_elements = [sys.argv[i] for i in range(1, len(sys.argv))]
    arguments = parse_arguments(arg_elements)

    # these arguments are mandatory
    cmd='net-output-extract'
    try:
        cmd=arguments['cmd']
    except:
        pass
    counts='label.counts'
    try:
        counts=arguments['class_frame_counts']
    except:
        pass
    options='--apply-log=true'
    try:
        options=arguments['options']
    except:
        pass
    model='nnet.final'
    try:
        model=arguments['model']
    except:
        pass
    feats='ark,s,cs:apply-cmvn --norm-vars=true --utt2spk=ark:data/eval2000/split12/2/utt2spk scp:data/eval2000/split12/2/cmvn.scp scp:data/eval2000/split12/2/feats.scp ark:- | splice-feats --left-context=1 --right-context=1 ark:- ark:- |'
    # 'subsample-feats --n=3 --offset=0 ark:- ark:- |'
    try:
        feats=arguments['feats']
    except:
        pass
    frames=3
    try:
        frames=int(arguments['frames'])
    except:
        pass

    command1=cmd+' --class-frame-counts='+counts+' '+options+' '+model+' "'+feats+'subsample-feats --n=3 --offset=0 ark:- ark:- |" ark:- |'
    command2=cmd+' --class-frame-counts='+counts+' '+options+' '+model+' "'+feats+'subsample-feats --n=3 --offset=1 ark:- ark:- |" ark:- |'
    command3=cmd+' --class-frame-counts='+counts+' '+options+' '+model+' "'+feats+'subsample-feats --n=3 --offset=2 ark:- ark:- |" ark:- |'

    # this programm acts like a filter
    for (key1,mat1),(key2,mat2),(key3,mat3) in itertools.izip(kaldi_io.read_mat_ark(command1), kaldi_io.read_mat_ark(command2), kaldi_io.read_mat_ark(command3)) :

        l=min(mat1.shape[0],mat3.shape[0])

        if mat1.shape[0] > l:
            mat1=mat1[0:l][:]
        if mat2.shape[0] > l:
            mat2=mat2[0:l][:]

        out=(mat1+mat2+mat3)/3

        kaldi_io.write_mat(sys.stdout,out,key=key1)
