#!/usr/bin/python

import numpy as np
import matplotlib.pyplot as plt
import csv
from xml.dom import minidom
from matplotlib.collections import LineCollection

xmldoc = minidom.parse('lead.dat')

file = "lattice.dat"
xml_shape_type  = xmldoc.getElementsByTagName('shape_type')
xml_shape_data  = xmldoc.getElementsByTagName('shape_data')
xml_lead_vector = xmldoc.getElementsByTagName('lead_vector')

shape_type = xml_shape_type[0].childNodes[0].nodeValue
print "Shape type  :",shape_type

shape_data = xml_shape_data[0].childNodes[0].nodeValue
f_shape_data = shape_data.split()
f_shape_data = [float(i) for i in f_shape_data]
print "Shape data  :" ,f_shape_data


xml_lead_vector = xml_lead_vector[0].childNodes[0].nodeValue
f_lead_vector   = xml_lead_vector.split()
f_lead_vector   = [float(i) for i in f_lead_vector]
print "Shape vector:",f_lead_vector

plt.clf()
f = plt.figure(1)    
ax  = plt.subplot(111)   
ax.set_aspect('equal')
ax.margins(0.1)

#shape_contour_x =  [f_shape_data[0],f_shape_data[2],f_shape_data[2],f_shape_data[0],f_shape_data[0]] 
#shape_contour_y =  [f_shape_data[1],f_shape_data[1],f_shape_data[3],f_shape_data[3],f_shape_data[1]] 
#ax.plot( shape_contour_x , shape_contour_y )
offset_x = [f_lead_vector[0]]*5
offset_y = [f_lead_vector[1]]*5
#ax.plot( map(add, shape_contour_x, offset_x)  , map(add, shape_contour_y, offset_y) )


import matplotlib.patches as patches

#ax3.add_patch(Polygon([[0,0],[4,1.1],[6,2.5],[2,1.4]], closed=True,
                      #fill=False, hatch='/')

if(shape_type == "SHAPE_RECTANGLE_XY"):
    ax.add_patch(
    patches.Rectangle(
        (f_shape_data[0], f_shape_data[1]),
        f_shape_data[2] - f_shape_data[0],
        f_shape_data[3] - f_shape_data[1],
        alpha=0.1,
        color='gray'
    )
    )
    ax.add_patch(
        patches.Rectangle(
            (f_shape_data[0]+f_lead_vector[0], f_shape_data[1]+f_lead_vector[1]),
            f_shape_data[2] - f_shape_data[0],
            f_shape_data[3] - f_shape_data[1],
            alpha=0.1,
            color='g'
        )
    )
if(shape_type == "SHAPE_CONVEX_QUAD_XY"):  
    coords = np.array(f_shape_data).reshape(4,2)
    offset = np.array([[f_lead_vector[0],f_lead_vector[1]]]*4)
    ax.add_patch(
        patches.Polygon(coords,
            alpha=0.2,
            color='gray'
        )
    )
    ax.add_patch(
        patches.Polygon(coords+offset,
            alpha=0.2,
            color='green'
        )
    )



# rebuild ends using none to separate line segments
wlist = []
lines = []
lead_datas = xmldoc.getElementsByTagName('lead_data')
for ldatas in lead_datas:
    ldata = ldatas.getElementsByTagName('data')
    
    for i in range(len(ldata)):        
        fdata = ldata[i].childNodes[0].nodeValue.split()
        fdata = fdata[0:7]
        fdata = [float(j) for j in fdata]        
        lines.append([ (fdata[0],fdata[1]) , (fdata[3],fdata[4]) ])
        wlist.extend([fdata[6]])


lc = LineCollection(lines, linewidths=wlist,colors='gray',lw=2.0)
ax.add_collection(lc)



# rebuild ends using none to separate line segments
wlist = []
lines = []
lead_datas = xmldoc.getElementsByTagName('next_cell_lead_data')
for ldatas in lead_datas:
    ldata = ldatas.getElementsByTagName('data')
    
    for i in range(len(ldata)):        
        fdata = ldata[i].childNodes[0].nodeValue.split()
        fdata = fdata[0:7]
        fdata = [float(j) for j in fdata]        
        lines.append([ (fdata[0],fdata[1]) , (fdata[3],fdata[4]) ])
        wlist.extend([fdata[6]])


lc = LineCollection(lines, linewidths=wlist,colors='green',lw=2.0)
ax.add_collection(lc)


# rebuild ends using none to separate line segments
wlist = []
lines = []
lead_datas = xmldoc.getElementsByTagName('lead_coupling')
for ldatas in lead_datas:
    ldata = ldatas.getElementsByTagName('data')
    
    for i in range(len(ldata)):        
        fdata = ldata[i].childNodes[0].nodeValue.split()
        fdata = fdata[0:7]
        fdata = [float(j) for j in fdata]        
        lines.append([ (fdata[0],fdata[1]) , (fdata[3],fdata[4]) ])
        wlist.extend([fdata[6]])


lc = LineCollection(lines, linewidths=wlist,colors='red',lw=2.0)
ax.add_collection(lc)

# rebuild ends using none to separate line segments
wlist = []
points = []
lead_datas = xmldoc.getElementsByTagName('nearest_atoms')
for ldatas in lead_datas:
    ldata = ldatas.getElementsByTagName('data')
    
    for i in range(len(ldata)):        
        fdata = ldata[i].childNodes[0].nodeValue.split()
        fdata = fdata[0:4]        
        fdata = [float(j) for j in fdata]              
        points.append([ fdata[0],fdata[1]])
        wlist.extend([fdata[3]])
        
points = np.array(points)
wlist = np.array(wlist)
ax.scatter(points[:,0],points[:,1], cmap='PuBu', c=wlist , s=10 , edgecolors='k' , zorder=2 )

plt.savefig("lead.pdf")