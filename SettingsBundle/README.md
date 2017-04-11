# Settings Bundle (iOS)
This is a tutorial using **Swift 3**

## WHY
In most cases, you may have some default settings of your app or you want to claim some information with your App. However, you don't have to put these whole things inside your app.

Fortunately, You can put these stuffs in iphone's **Settings**!

<img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/demo.png" width="270" height="480" />
<img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/map.PNG" width="270" height="480" />
<img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/excel.PNG" width="270" height="480" />


## How
Open your project, 
- File > New > File...(⌘N)
- Under iOS, Resource > Settings Bundle
- Name the file **Settings.bundle**

<img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/create.png" />


The Settings bundle has the following structure:
```
Settings.bundle/
    Root.plist
    en.lproj/
        Root.strings
```
Open Root.plist, you will see

 <img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/origin.png"/>


Build and Run the App. Then go to the **Settings** on your iphone. Find your App down below.
Here's the defulat of the seetings bundle.

 <img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/default.png" width="270" height="480" />

## Get Started
OK, let's get started with our custom settings.

 <img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/demoSetting.PNG" width="270" height="480" />

We have 3 Groups:
- Group 1

  >Text
  
  >Switch
  
- Group 2

  >Slider
  
  >Options
  
- Custom

  > Segue to another plist
  
  > Footer

  
  
So, Root.plist will look like 

 <img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/RootPlist.png"/>
 
Down below **Preference Items**, you can add your [preferences](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html)

- [x] Text Field
- [x] Title
- [x] Toggle Switch
- [x] Slider
- [x] Multi Value
- [x] Group
- [x] Child Pane

## Details
### Group
- Type : Group
- Title : Header's here
- FooterText: some information you want to say ... (Optional)

```plist
<dict>
		<key>Type</key>
		<string>PSGroupSpecifier</string>
		<key>Title</key>
		<string>Group 1</string>
</dict>
```

>**Title** will be always **uppercase** string.

>**FooterText** will be present as normal cases.

In this tutorail, there is **FooterText** in the last Group.
```plist
<dict>
	<key>Type</key>
	<string>PSGroupSpecifier</string>
	<key>Title</key>
	<string>Custom</string>
	<key>FooterText</key>
	<string>Copyright © 2016 Hello World!More Information? Put something down below..</string>
</dict>
```
*Tips:* you can copy unicode just in plist in string tag, or you can try this way ..
```plist
<string>&#X00A9;</string>
```



### Title
- Type : Title
- Title : Version
- Identifier : version_preferece
- Default Value : 9.9.9

```plist
<dict>
		<key>Type</key>
		<string>PSTitleValueSpecifier</string>
		<key>Title</key>
		<string>Version</string>
		<key>Key</key>
		<string>version_preference</string>
		<key>DefaultValue</key>
		<string>9.9.9</string>
</dict>
```

### Switch
- Type : Toggle Switch
- Title : Enable
- Identifier : enable_preferece
- Default Value : YES


```plist
<dict>
		<key>Type</key>
		<string>PSToggleSwitchSpecifier</string>
		<key>Title</key>
		<string>Enabled</string>
		<key>Key</key>
		<string>enabled_preference</string>
		<key>DefaultValue</key>
		<true/>
	</dict>
```

### Slider
- Type : Slider
- Identifier : slider_preferece
- Default Value : 0.5
- Minimum Value : 0
- Maximum Value : 1

```plist
<dict>
		<key>Type</key>
		<string>PSSliderSpecifier</string>
		<key>Key</key>
		<string>slider_preference</string>
		<key>DefaultValue</key>
		<real>0.5</real>
		<key>MinimumValue</key>
		<integer>0</integer>
		<key>MaximumValue</key>
		<integer>1</integer>
		<key>MinimumValueImage</key>
		<string></string>
		<key>MaximumValueImage</key>
		<string></string>
	</dict>
```

### Options
- Type : Multi Value
- Identifier : choice_preferece
- Default Value : A

<img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/Choice.PNG" width="270" height="480" />
<img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/Choice_detail.PNG" width="270" height="480" />

**You have to define your options here**

Add row > Titles

- Item0 : A
- Item1 : B
- Item2 : C

Add row > Values

- Item0 : A
- Item1 : B
- Item2 : C

```plist
<dict>
	<key>Type</key>
		<string>PSMultiValueSpecifier</string>
		<key>Title</key>
		<string>Choices</string>
		<key>Key</key>
		<string>choice_preference</string>
		<key>DefaultValue</key>
		<string>A</string>
		<key>Titles</key>
		<array>
			<string>A</string>
			<string>B</string>
			<string>C</string>
		</array>
		<key>Values</key>
		<array>
			<string>A</string>
			<string>B</string>
			<string>C</string>
		</array>
</dict>
```

### Custom
- Type : Child Pane
- Filename : Acknowledgements (your custom plist)
- Title : Acknowledgements

<img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/Ack.PNG" width="270" height="480" />
<img src="https://github.com/Weijay/READMEs/blob/master/SettingBundle/Ack_Detail.PNG" width="270" height="480" />

You have to create a new File
- [x] create a new File > "Acknowledgemet.plist"
- [x] Add the following inside and Save
``` plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>StringsTable</key>
	<string>Acknowledgements</string>
	<key>PreferenceSpecifiers</key>
	<array>
		<dict>
			<key>Title</key>
			<string>
			XXXKit is available under the MIT license.
			
			Copyright (c) 2012 ZZZ
			
			Permission is hereby granted, free of charge, to any person obtaining a copy
			of this software and associated documentation files (the &quot;Software&quot;), to deal
			in the Software without restriction, including without limitation the rights
			to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
			copies of the Software, and to permit persons to whom the Software is
			furnished to do so, subject to the following conditions:
			
			The above copyright notice and this permission notice shall be included in
			all copies or substantial portions of the Software.
			
			THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
			IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
			FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
			AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
			LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
			OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
			THE SOFTWARE.
			</string>
			<key>Type</key>
			<string>PSGroupSpecifier</string>
		</dict>
	</array>
</dict>
</plist>
```

## More
This settings bundle can be your default settings. Also, you can get and set the value when your app is launched.

In **ViewController.swift**, here's a demo of **GET** and **SET** what mentioned above.

> Set version of your App.
```swift
    func updateVersion() {
        let version = Bundle.main.objectForInfoDictionaryKey("CFBundleShortVersionString")!
        print("version: \(version)")
        UserDefaults.standard.set(version, forKey: "version_preference")
    }
```

> Get value of your choices.
```swift
    func getChoices() {
        // First you should register your defaults so everything is sync'd up and defaults are assigned. Then you'll know a value exists. These values are not automatically synchronized on startup.
        var appDefaults = Dictionary<String, AnyObject>()
        appDefaults["choice_preference"] = "A" // default value
        UserDefaults.standard.register(appDefaults)
        UserDefaults.standard.synchronize()
        let choiceValue = UserDefaults.standard.string(forKey: "choice_preference")
        print("choice is \(choiceValue)")
    }
```
Keep in mind that you should also use registerDefaults: when your app uses a Settings Bundle. Since you already specified default values inside the settings bundle’s plist, you may expect that your app picks these up automatically. However, that is not the case. The information contained in the settings bundle is only read by the iOS Settings.app and never by your app. In order to have your app use the same defaults as shown inside the Settings.app, you have to manually copy the user defaults keys and their default values into a separate plist file and register it with the defaults database as shown above.
