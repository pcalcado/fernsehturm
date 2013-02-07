fernsehturm
===========

Information Radiator Experiments

## Philips Hue
Trying it as a cheaper(!!) replacement for
[Delcom lights](http://www.delcomproducts.com/products_usblmp.asp).

Pics of the default colours:

![](https://raw.github.com/pcalcado/fernsehturm/master/pics/hue_off.jpg)
![](https://raw.github.com/pcalcado/fernsehturm/master/pics/hue_red.jpg)
![](https://raw.github.com/pcalcado/fernsehturm/master/pics/hue_blue.jpg)
![](https://raw.github.com/pcalcado/fernsehturm/master/pics/hue_yellow.jpg)

```ruby
app = App.new("test") #can be anything
bridge = Bridge.new("10.23.69.143") #you can get the bridge's IP from the Hue web app

app.connect_to!(bridge)
app.change_colours!(1, Colours::BRIGHT + Colours::RED + Colours::FLICKERING)
```
