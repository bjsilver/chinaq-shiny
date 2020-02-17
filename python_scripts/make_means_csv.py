#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 13 13:57:54 2020

@author: eebjs
"""

import os
import xarray as xr
import pandas as pd
from tqdm import tqdm
from statsmodels.tsa.seasonal import seasonal_decompose


cdf_fpath = '/nfs/a68/eebjs/bja_ncs_2020update/'

stations = os.listdir(cdf_fpath)
stations = [s[:-3] for s in stations if s.split('.')[-1] == 'nc']

pol = 'PM2.5'

def get_seas_decomp_trend(df):
    # resample to daily mean
    df = df.resample('D').mean()
    
    # ffill missing values
    df = df.ffill()
    # bfill missing values
    df = df.bfill()
    
    # get seasonal decompositio
    sd = seasonal_decompose(df, model='add', freq=365)
    
    return(sd)
    
def check_timeseries_df(df):
    # check greater than 85% data available
    if df.count()/len(df) < .85:
#        print(station, 'less than 85% available')
        return(False)
    # check more than 3 years of data available
    elif df.index[-1] - df.index[0] < pd.Timedelta('1095 days 00:00:00'):
        return(False)
    else:
        return(True)

poldfs = []
for pol in ['PM2.5', 'SO2', 'NO2', 'O3', 'PM10']:
    decomposed_series = []
    for station in tqdm(stations):
        
        ds = xr.open_dataset(cdf_fpath+station+'.nc')
        ds = ds.set_index({'time':'times'})
        df = ds[pol].to_pandas()
        
        df = df.loc[~df.index.duplicated(keep='first')] # drop duplicates
        # create index
        start, end = ds.time[[0, -1]].values
        index = pd.date_range(start=start, end=end, freq='H')
        df = df.reindex(index)
        
        if not check_timeseries_df(df):
            print(station, 'skipped')
            continue
        
        # get seasonal decomp
        sd = get_seas_decomp_trend(df)
        decomptrend = sd.trend
        
        # resample to month
        decomptrend = decomptrend.dropna()
        decomptrend = decomptrend.resample('MS').mean()
        decomptrend.index = decomptrend.index.strftime("%Y-%m-%d")
        
        # make lat/lon series
        lls = pd.Series(index=['lat', 'lon'], data=[ds.station_lat, ds.station_lon])
        
        # prepend to decomptrend
        decomptrend = pd.concat([lls, decomptrend])
        
        # append lon+lat
        
        decomposed_series.append(decomptrend)
        decomptrend.name = station
        ds.close()
        
    
    
    tsdf = pd.concat(decomposed_series, axis=1)
    tsdf = tsdf.T
    tsdf.index.name = 'station'
    tsdf['pol'] = pol
    
    
    poldfs.append(tsdf)
tsdf_concat = pd.concat(poldfs)

tsdf_concat.to_csv('./shiny_map/china_aqtrends/decomposed_means.csv')