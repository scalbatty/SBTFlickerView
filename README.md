SBTFlickerView
==========

SBTFlickerView is a couple of classes that represent a visual carousel, allowing you to put an infinite number of same-size "clips" in an horizontal scrollview, with the possibility of paging.

Backlog
----------

* Use ARC
* Allow linking to DataSource and Delegate through Interface Builder
* Allow 

How to install
------------------

1. Copy the following files into your project :
	* SBTFlickerView.h
	* SBTFlickerView.m
	* SBTFlickerViewClip.h
	* SBTFlickerViewClip.m
2. Start using SBTFlickerView in your app !

How to use
--------------

SBTFlickerView works like a UITableView, it needs a DataSource and may need a Delegate (for action callbacks). The delegate and datasource protocols are quite straightforward and the file SBTMainViewController in the demo project is a good starting point.

There are several properties you can use to tweak the SBTFlickerView to your will :

* `ClipSize` : The size of the clips to display. Defaults to the size of the Flickerview frame
* `ClipSpacing` : The horizontal space between clips
* `ClipsPerPage` : If you want to display multiple clips at the same time, you have to change this property.

You can put a SBTFlickerView in your XIB (using the identity panel).

