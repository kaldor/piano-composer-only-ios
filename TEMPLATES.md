# Templates
We recommend to use that tag in mobile templates for correct display on iOS devices
```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

## Imports
```swift
// swift
import PianoTemplate
```
```obj-c
// objective-c
@import PianoTemplate;
```

## Show template

PianoTemplate uses the ```ShowTemplateEventParams``` from the PianoComposer component to display templates. Implement the ```PianoComposerDelegate.showTemplate``` function to get these parameters. 

### Modal template view
```swift
func showTemplate(composer: PianoComposer, event: XpEvent, params: ShowTemplateEventParams?) {
    guard let p = params else {
        return
    }
    
    PianoShowTemplateController(params: p).show()
}
```

### Inline template view
```swift
class MyDelegate: PianoComposerDelegate, PianoShowTemplateDelegate {

    var webView: WKWebView
    
    func findViewBySelector(selector: String) -> UIView? {
        guard selector == "my_selector_name" else {
            return nil
        }
        return webView
    }

    func showTemplate(composer: PianoComposer, event: XpEvent, params: ShowTemplateEventParams?) {
        guard let p = params else {
            return
        }
        
        let controller = PianoShowTemplateController(params: p)
        controller.delegate = self
        controller.show()
    }

    ...
}

```

## Show form

To display forms, you need to implement the ```PianoComposerDelegate.showForm``` method.

Import PianoTemplate.ID and PianoOAuth components:
```swift
import PianoTemplate_ID
import PianoOAuth
```

Implment method:
```swift
func showForm(composer: PianoComposer, event: XpEvent, params: ShowFormEventParams?) {
    guard let p = params else {
        return
    }
    
    let form = PianoID.shared.form(params: params)
    form.show()
}
```

You can override the authorization method if the user is not authorized (by default, the ```PianoID.shared.signIn``` method is used):
```swift
func showForm(composer: PianoComposer, event: XpEvent, params: ShowFormEventParams?) {
    ...
    form.signIn = { callback in
        myAuthFunc() { accessToken in
            ...
            callback(accessToken)
        }
    }
    ...
}
```

You can override the function that processes the result of filling out the form (if the function is not defined, then the form filling check will not be executed):
```swift
func showForm(composer: PianoComposer, event: XpEvent, params: ShowFormEventParams?) {
    ...
    form.hideIfCompleted = {
        ...
        print("Form filled")
    }
    ...
}
```

You can also handle an error (when authorizing or checking the completion of the form):
```swift
func showForm(composer: PianoComposer, event: XpEvent, params: ShowFormEventParams?) {
    ...
    form.error = { error in
        ...
        print(error)
    }
    ...
}
```

### Inline form
To display an inline form, you need to override the delegate and the PianoTemplateInlineDelegate.findViewBySelector method (same as implemented in templates) and set the delegate:
```swift
func showForm(composer: PianoComposer, event: XpEvent, params: ShowFormEventParams?) {
    ...
    form.controller.delegate = self
    ...
}
```

## Show recomendations

To display recommendations, you need to implement the ```PianoComposerDelegate.showRecommendations``` method.

Import PianoC1X components:
```swift
import PianoC1X
```

Implment method:
```swift
func showRecommendations(composer: PianoComposer, event: XpEvent, params: ShowRecommendationsEventParams?) {
    guard let p = params else {
        return
    }
    
    PianoC1X.recommendations(params: params).show()
}
```

### Inline recommendations

You need to implement PianoTemplateInlineDelegate and set it for recommendation controller (same as implemented in templates):
```swift
func showRecommendations(composer: PianoComposer, event: XpEvent, params: ShowRecommendationsEventParams?) {
    ...
    let controller = PianoC1X.recommendations(params: params)
    controller.delegate = self
    ...
}
```
