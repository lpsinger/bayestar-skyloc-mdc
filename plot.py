#!/usr/bin/env python

# Command line interface.
from optparse import Option, OptionParser
opts, args = OptionParser(
    option_list = [
        Option("--cumulative", action="store_true")
    ]
).parse_args()

# Imports.
import matplotlib
matplotlib.use('agg')
from matplotlib import pyplot as plt
import os
import numpy as np
from pylal.progress import ProgressBar

pb = ProgressBar()

pb.update(-1, 'reading data')

#toa_data_ = np.recfromtxt('toa.out', names=True)
toa_snr_data_ = np.recfromtxt('outdata.txt', names=['far', 'searched_area', 'searched_prob', 'offset'])
fars = toa_snr_data_['far']

log10_min_far = int(np.ceil(np.log10(np.min(fars))))
log10_max_far = int(np.ceil(np.log10(np.max(fars))))
pb.max = (log10_max_far - log10_min_far + 1) * 4

for i, log10_far in enumerate(range(log10_min_far, log10_max_far + 1)):
    pb.update(text='FAR <= 1e{0} Hz'.format(log10_far))

    far = 10 ** log10_far
    predicate = (fars <= far)    

    datasets = [toa_snr_data_[predicate]]
    labels = ['TOAs and SNRs']
    title = r'$\mathrm{{FAR}} \leq 10^{{{0}}}$ Hz ({1} events)'.format(log10_far, sum(predicate))
    subdir = 'far_1e{0}'.format(log10_far)
    os.mkdir(subdir)
    os.chdir(subdir)

    combined_datasets = np.hstack(datasets)
    min_searched_area = combined_datasets['searched_area'].min()
    max_searched_area = combined_datasets['searched_area'].max()
    min_offset = combined_datasets['offset'].min()
    max_offset = combined_datasets['offset'].max()

    plt.figure(1, figsize=(4, 4))
    plt.subplot(111, aspect=1)
    plt.subplots_adjust(bottom=0.15)
    plt.xlim(0, 1)
    plt.ylim(0, 1)
    plt.xlabel('searched posterior mass')
    plt.ylabel('cumulative fraction of injections')
    plt.title(title)

    plt.figure(2, figsize=(4, 3))
    plt.subplots_adjust(bottom=0.15)
    plt.xlim(0, 1)
    plt.xlabel('searched posterior mass')
    plt.ylabel('number of injections')
    plt.title(title)

    plt.figure(3, figsize=(4, 3))
    plt.xscale('log')
    plt.subplots_adjust(bottom=0.15)
    plt.xlabel('searched area (deg$^2$)')
    plt.ylabel('number of injections')
    plt.title(title)

    plt.figure(4, figsize=(4, 3))
    plt.xscale('log')
    plt.subplots_adjust(bottom=0.15)
    plt.xlabel('angle between true location and mode of posterior')
    plt.ylabel('number of injections')
    plt.title(title)

    for (data, label) in zip(datasets, labels):
    	plt.figure(1)
    	plt.plot(np.sort(data['searched_prob']), np.linspace(0, 1, len(data['searched_prob'])), label=label)
    	plt.figure(2)
    	plt.hist(data['searched_prob'], histtype='step', label=label, bins=np.linspace(0, 1, 20), cumulative=opts.cumulative)
    	plt.figure(3)
    	plt.hist(data['searched_area'], histtype='step', label=label, bins=np.logspace(np.log10(min_searched_area), np.log10(max_searched_area), 20), cumulative=opts.cumulative)
    	plt.figure(4)
    	plt.hist(data['offset'], histtype='step', label=label, bins=np.logspace(np.log10(min_offset), np.log10(max_offset), 20), cumulative=opts.cumulative)

    pb.update(i * 4)
    plt.figure(1)
    plt.plot([0, 1], [0, 1], '--', color='0.75')
    plt.grid()
    plt.legend(loc='lower right')
    plt.savefig('searched_prob.pdf')
    plt.close()

    pb.update(i * 4 + 1)
    plt.figure(2)
    plt.grid()
    plt.legend(loc='upper left')
    plt.savefig('searched_prob_hist.pdf')
    plt.close()

    pb.update(i * 4 + 2)
    plt.figure(3)
    plt.grid()
    plt.savefig('searched_area_hist.pdf')
    plt.close()

    pb.update(i * 4 + 3)
    plt.figure(4)
    plt.grid()
    plt.savefig('offset_hist.pdf')
    plt.close()

    os.chdir(os.pardir)
