#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  3 15:14:22 2020

@author: eebjs
"""

import os 
import xarray as xr
import pandas as pd
idx = pd.IndexSlice
import numpy as np
from tqdm import tqdm
import matplotlib.pyplot as plt

def ppol(string):
    pretty_string = ''

    if (string == 'PM2.5') | (string == 'PM2_5_DRY'):
        pretty_string = '$\\mathrm{PM_{2.5}}$'
    elif string == 'PM2.5_10':
        pretty_string = '$\\mathrm{PM_{2.5}:PM_{10}}$'
    elif string == 'PM10':
        pretty_string = '$\\mathrm{PM_{10}}$'
    elif string == 'PM2.5_CO':
        pretty_string = '$\\mathrm{PM_{2.5}:CO}$'
    elif string == 'ug/m3':
        pretty_string = '$\mathrm{\mu g/m^3}$'
    elif (string == 'mg/m3') | (string == 'mg m^-3'):
        pretty_string = '$\mathrm{mg/m^3}$'
    elif (string == 'ugm-3') | (string == 'ug m^-3'):
        pretty_string = '$\mathrm{\mu g \ m^{-3}}$'
    elif string[:4] == 'unit':
        if string[4:] == 'CO':
            pretty_string = '$\mathrm{mg/m^3}$'
        else:
            pretty_string = '$\mathrm{\mu g/m^3}$'
    elif string == 'ugm-3py':
        pretty_string = '$\mathrm{\mu g \ m^{-3}\ year^{-1}}$'
    elif string == 'pyr':
        pretty_string = '$\mathrm{year^{-1}}$'
    elif string == 'O3_mda8':
        pretty_string = '$\mathrm{O_{3}MDA8}$'
    elif string == 'PM2_5_DRY_e':
        pretty_string = '$\\mathrm{PM_{2.5}\ DRY}$'
    else:
        for letter in string:
            if letter.isalpha():
                if letter.islower():
                    letter = letter.upper()
                pretty_string = pretty_string + letter
            else:
                pretty_string = pretty_string + '_{'+letter+'}'


        pretty_string = '$\mathrm{'+pretty_string+'}$'

    return(pretty_string)


cdf_fpath = '/nfs/a68/eebjs/bja_ncs_2020update/'

stations = os.listdir(cdf_fpath)
stations = [s[:-3] for s in stations if s.split('.')[-1] == 'nc']


for pol in ['PM10', 'NO2', 'SO2', 'O3']:
    
    trenddf = pd.read_csv('theilsen_trends.csv', index_col =[0,1])
    trenddf = trenddf.loc[idx[:,pol], :] # slice by pol
    
    for station in tqdm(stations):
        
        
    
        ds = xr.open_dataset(cdf_fpath+station+'.nc')
        ds = ds.set_index({'time':'times'})
        df = ds[pol].to_pandas()
        df = df.loc[~df.index.duplicated(keep='first')] # drop duplicates
        # create index
        start, end = ds.time[[0, -1]].values
        index = pd.date_range(start=start, end=end, freq='H')
        
        df = df.reindex(index)
        
        td = trenddf.loc[station]
            
        fig, ax = plt.subplots(figsize=[5, 3])
        meandf = df.rolling('30D').mean()
        meandf = meandf.dropna()
        meandf.name = '30-day rolling mean'
        meandf = pd.DataFrame(meandf)
        
        
        # calculate y0 and y1
        first = meandf.index[0]
        last = meandf.index[-1]
        x0 = first.year-1970 + (first.dayofyear-1 + (first.hour/24))/365
        x1 = last.year-1970 + (last.dayofyear-1 + (last.hour/24))/365
        y0 = td['slope']*x0+td['a']
        y1 = td['slope']*x1+td['a']
        lin = np.linspace(y0, y1, len(meandf))
        meandf.loc[:, 'TheilSen'] = lin
    
        meandf.plot(ax=ax)
        
        #  set title
        titletext = station+' '+ppol(pol) +': ' + ds.attrs['station_name_en'] + ', ' +\
        ds.attrs['city_en'] + ', ' + ds.attrs['province'] 
        ax.set_title(titletext, fontsize=10)
        ax.get_legend().remove()
        
        # set labels
        ax.set_ylabel(ppol(pol) +' ' +ppol('ugm-3'))
        
        # add trend text
        trendtext = str(round(float(td['slope']), 2)) +' '+ ppol('ugm-3') +\
        ' '+ ppol('pyr')
        ax.text(.6, .9, trendtext, transform=ax.transAxes, color='#ff7f0e')
        
        plt.tight_layout()
        
        plt.savefig('/nfs/see-fs-02_users/eebjs/public_html/station_svgs/'+\
                    pol +'_'+station+'.svg')
        
        plt.close()
        ds.close()
        