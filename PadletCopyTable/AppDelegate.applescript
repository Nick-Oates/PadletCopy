--
--  AppDelegate.applescript
--  PadletCopyTable
--
--  Created by Nick Oates on 22/12/2022.
--  
--

use framework "Foundation"
use scripting additions
use script "RegexAndStuffLib" version "1.0.7"

property NSMutableArray : class "NSMutableArray"
property NSString : class "NSString"
property NSNumber : class "NSNumber"
property NSColor : class "NSColor"
--property NSTimer : class "NSTimer"
property MyTimer : class "MyTimer"

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value
    property theTableView : missing value
    property buttonName1 : missing value
    property buttonName2 : missing value
    property buttonName3 : missing value
    property buttonName4 : missing value
    property buttonHidden2 : missing value
    property buttonHidden3 : missing value
    property buttonHidden4 : missing value
    property counter : missing value
    property checkboxHidden : missing value
    property clearTarget : missing value

    property theScript : missing value
    property isRunning : missing value
    property sourceName : missing value
    property sourceType : missing value
    property targetName : missing value
    property startTime : missing value
    property pauseDuration : missing value
    property pauseTime : missing value
    property startTimeDisplay : missing value
    property pauseHidden : missing value
    property pauseDisplay : missing value
    property paused : missing value
    property theTimer : missing value
    property tickInterval : missing value

    property controlDoc : missing value
    property controlPosts : missing value
    property dashboardDoc : missing value
    property sourceDoc : missing value
    property sourcePosts : missing value
    property targetDoc : missing value
    property targetPosts : missing value

    property padletTypes : {"canvas", "map", "shelf", "timeline"}

    property errorMessage : missing value
    property errorHidden : missing value
    property errorColour : missing value
    
    -- Javascript code blocks ---------------------------------------------------------------------
    property padletTypeScript : "function getPadletType() {
            const htmlEl = document.documentElement;
            let padletType = 'unknown';
            
            if(htmlEl) {
                let pType = htmlEl.getAttribute('data-layout');

                if(pType) {
                    pType = pType.toLowerCase();
                    if(pType == 'free') {
                        padletType = 'canvas';
                    }
                    else {
                        padletType = pType;
                    }
                }
            }
            
            return padletType;
        }
        
        getPadletType();"
    property canvasPostsScript : "function getCanvasPosts() {
            const postEls = document.getElementsByClassName('surface-post');
            const posts = [];
            
            for(let p=0; p<postEls.length; p++) {
                const postEl = postEls[p];
                const subjectEl = postEl.querySelector('[data-cy=postSubject]');
                const contentEl = postEl.querySelector('p div');
                
                if(!subjectEl) {
                    continue;
                }
                
                let id = postEl.id;
                
                if(!id) {
                    id = '-';
                }
                
                const title = subjectEl.innerText;
                let content = '';
                
                if(contentEl) {
                    content = contentEl.innerHTML.replace(/\\n/g, '').replace(/<br>/g, '\\n').replace(/<[^<]+>/, '');
                }
                const pRect = subjectEl.getBoundingClientRect();
                const rect = [pRect.x, pRect.y, pRect.width, pRect.height];
                
                const post = [id, title, content, rect];
                posts.push(post);
            }
            
            return posts;
        }
        
        getCanvasPosts();"
    property mapPostsScript : "function getMapPosts() {
            const postEls = document.querySelectorAll('[role=menuitem]');
            const posts = [];
            
            for(let p=0; p<postEls.length; p++) {
                const postEl = postEls[p];
                const spans = postEl.querySelectorAll('span');
                
                let id = postEl.id;
                
                if(!id) {
                    id = '-';
                }
                
                if(spans.length < 2) {
                    continue;
                }
                
                const title = spans[1].innerText.trim();

                const post = [id, title, '', []];
                posts.push(post);
            }
            
            return posts;
        }
        
        getMapPosts();"
    property shelfPostsScript : "function getShelfPosts() {
            const sectionEls = document.querySelectorAll('section');
            const sections = [];
            
            for(let s=0; s<sectionEls.length; s++) {
                const sectionEl = sectionEls[s];
                const titleEl = sectionEl.querySelector('h2');
                
                if(!titleEl) {
                    continue;
                }
                
                const sTitle = titleEl.innerText.trim();
                
                let sId = sectionEl.id;
                if(!sId) {
                    sId = '-';
                }
                
                const postEls = sectionEl.getElementsByClassName('surface-post');
                const posts = [];
                
                for(let p=0; p<postEls.length; p++) {
                    const postEl = postEls[p];
                    
                    const subjectEl = postEl.querySelector('h3');
                    const contentEl = postEl.querySelector('p div');
                
                    if(!subjectEl) {
                        continue;
                    }
                
                    let id = postEl.id;
                
                    if(!id) {
                        id = '-';
                    }
                
                    const title = subjectEl.innerText;
                    let content = '';
                
                    if(contentEl) {
                        content = contentEl.innerHTML.replace(/\\n/g, '').replace(/<br>/g, '\\n').replace(/<[^<]+>/, '');
                    }
                
                    const post = [id, title, content, false];
                    posts.push(post);
                }
                
                const section = [sId, sTitle, posts];
                sections.push(section)
            }
            
            return sections;
        }
        
        getShelfPosts();"
    property timelinePostsScript : "function getTimelinePosts() {
            const postEls = document.getElementsByClassName('surface-post');
            const posts = [];
            
            for(let p=0; p<postEls.length; p++) {
                const postEl = postEls[p];
                const subjectEl = postEl.querySelector('[data-cy=postSubject]');
                const contentEl = postEl.querySelector('p div');

                if(!subjectEl) {
                    continue;
                }
                
                let id = postEl.id;
                
                if(!id) {
                    id = '-';
                }
                
                const title = subjectEl.innerText;
                let content = '';
                
                if(contentEl) {
                    content = contentEl.innerHTML.replace(/\\n/g, '').replace(/<br>/g, '\\n').replace(/<[^<]+>/, '');
                }

                const post = [id, title, content, false];
                posts.push(post);
            }
            
            return posts;
        }
        
        getTimelinePosts();"
    property getDocScript : "function getDoc(docName) {
            const padlets = [];
            let index = 0;
            
            while(index >= 0) {
                const block = document.querySelector('[data-cy=padletCard' + index + ']');
                
                if(block) {
                    const link = block.querySelector('a');
                    const img =  block.querySelector('a div img');
                    if(link && img) {
                        if(img.getAttribute('alt').toLowerCase() == docName.toLowerCase()) {
                            link.click();
                            return true;
                        }
                    }
                    
                    index++;
                }
                else {
                    index = -1;
                }
            }
            
            return false;
        }
        
        getDoc('@docName@');"
    property fetchPostIdsScript : "function fetchPostIds() {
            const postEls = document.getElementsByClassName('surface-post');
            const postIds = [];
            
            for(let p=0; p<postEls.length; p++) {
                const postEl = postEls[p];
                
                postIds.push(postEl.id);
            }
            
            return postIds;
        }
        
        fetchPostIds();"
    property activateEditScript : "function activateEdit(postId) {
            const postEl = document.getElementById(postId);
            const buttons = postEl.querySelectorAll('button');
            let editButton = false;
                    
            for(const button of buttons) {
                if(button.title == 'More post actions') {
                    editButton = button;
                    break;
                }
            }
            if(!editButton) {
                return false;
            }
            editButton.click();
            return true;
        }
        
        activateEdit(@activateEditAttr@);"
    property activateDuplicateScript : "function activateDuplicate() {
            const buttons = document.querySelectorAll('[role=menuitem]');
            let dupButton = false;

            for(const button of buttons) {
                const div = button.querySelector('div');
                if(div.title == 'Duplicate post') {
                    dupButton = button;
                    break;
                }
            }
            if(!dupButton) {
                return false;
            }
            dupButton.click();
            return true;
        }
        
        activateDuplicate();"
    property activateDeleteScript : "function activateDelete() {
            const buttons = document.querySelectorAll('[role=menuitem]');
            let delButton = false;

            for(const button of buttons) {
                const div = button.querySelector('div');
                if(div.title == 'Delete post') {
                    delButton = button;
                    break;
                }
            }
            if(!delButton) {
                return false;
            }
            delButton.click();
            return true;
        }
        
        activateDelete();"
    property deletePostScript : "function deletePost() {
            const buttons = document.querySelectorAll('[role=dialog] button');
            let delButton = false;

            for(const button of buttons) {
                const div = button.querySelector('div');
                if(div.title == 'Delete post') {
                    delButton = button;
                    break;
                }
            }
            if(!delButton) {
                return false;
            }
            delButton.click();
            return true;
        }
        
        deletePost();"
    property selectTargetScript : "function selectTarget(targetName) {
            const targets = document.querySelectorAll('.side-panel [role=listitem] h3');

            for(const target of targets) {
                if(target.innerText.toLowerCase() === targetName.toLowerCase()) {
                    const link = target.parentElement.parentElement.parentElement;
                    link.click();
                    return true;
                }
            }

            return false;
        }
        
        selectTarget(@selectTargetAttr@);"
    property fetchPostIdScript : "function fetchPostId(postTitle) {
            const postEls = document.getElementsByClassName('surface-post');
            
            for(const postEl of postEls) {
                const title = postEl.querySelector('[data-cy=postSubject]');
                
                if(title.innerText === postTitle) {
                    return postEl.id;
                }
            }

            document.location.reload();
            return '';
        }
        
        fetchPostId(@fetchPostIdAttr@);"
    property moveResizePostScript : "function fireMouseEvent(type, elem, posX, posY) {
            const evnt = document.createEvent('MouseEvents');
            evnt.initMouseEvent(type, true, true, window, 1, 1, 1, posX, posY, false, false, false, false, 0, elem);
            elem.dispatchEvent(evnt);
        }

        function mouseDrag(el, fromX, fromY, toX, toY) {
            // mouse over post and mousedown
            fireMouseEvent('mousemove', el, fromX, fromY);
            fireMouseEvent('mouseenter', el, fromX, fromY);
            fireMouseEvent('mouseover', el, fromX, fromY);
            fireMouseEvent('mousedown', el, fromX, fromY);

            // start dragging process
            fireMouseEvent('dragstart', el, fromX, fromY);
            fireMouseEvent('drag', el, fromX, fromY);
            fireMouseEvent('mousemove', el, fromX, fromY);
            fireMouseEvent('drag', el, toX, toY);
            fireMouseEvent('mousemove', el, toX, toY);

            // release dragged post in new position
            fireMouseEvent('dragend', el, toX, toY);
            fireMouseEvent('mouseup', el, toX, toY);
        }

        function movePost(postEl, fromX, fromY, fromWidth, toX, toY) {
            if(toX == fromX && toY == fromY) {
                return true;
            }
            
            const x1 = fromX + Math.floor(fromWidth / 2);
            const y1 = fromY + 10;
            const x2 = toX + Math.floor(fromWidth / 2);
            const y2 = toY + 10;

            mouseDrag(postEl, x1, y1, x2, y2);
            return true;
        }

        function resizePost(postEl, fromWidth, fromHeight, toWidth, toHeight) {
            if(fromWidth == toWidth && fromHeight == toHeight) {
                return true;
            }
            
            const resizeBox = postEl.querySelector('.ui-icon-gripsmall-diagonal-se');
            if(!resizeBox) {
                return false;
            }
            
            const rect = resizeBox.getBoundingClientRect();
            const x1 = rect.left + Math.floor(rect.width / 2);
            const y1 = rect.top + Math.floor(rect.height / 2);
            const x2 = x1 + toWidth - fromWidth;
            const y2 = y1 + toHeight - fromHeight;
            
            mouseDrag(resizeBox, x1, y1, x2, y2);
            return true;
        }

        function moveResizePost(postId, toX, toY, toWidth, toHeight) {
            const postEl = document.getElementById(postId);
            
            if(!postEl) {
                return -1;
            }

            const postRect = postEl.getBoundingClientRect();
            const fromX = postRect.x;
            const fromY = postRect.y;
            const fromWidth = postRect.width;
            const fromHeight = postRect.height;
            
            if(fromX != toX || fromY != toY) {
                const success = movePost(postEl, fromX, fromY, fromWidth, toX, toY);
            
                if(!success) {
                    return -2;
                }
            }
            
            if(fromWidth != toWidth || fromHeight != toHeight) {
                const success = resizePost(postEl, fromWidth, fromHeight, toWidth, toHeight);
                   
                if(!success) {
                    return -3;
                }
            }

            return 1;
        }
    
        moveResizePost(@moveResizePostAttr@);"
    -- END Javascript code blocks -----------------------------------------------------------------

    -- application initialisation and shut down methods ----------------------------------------------
	on applicationWillFinishLaunching_(aNotification)
        setIsRunning_(false)
        setTheScript_(NSMutableArray's alloc()'s init())
        setSourceName_("")
        setTargetName_("")
        setStartTime_(0)
        setPauseTime_(0)
        setPauseDuration_(0)
        setStartTimeDisplay_("")
        setPauseHidden_(true)
        setPauseDisplay_("")
        setPaused_(false)
        setButtonName1_("Load script")
        setButtonName2_("Cancel")
        setButtonHidden2_(false)
        setButtonHidden3_(true)
        setButtonHidden4_(true)
        setCheckboxHidden_(true)
        setClearTarget_(true)
        setErrorHidden_(true)
        setErrorColour_(NSColor's blackColor)
        setCounter_(0)
        set timerInterval to NSNumber's numberWithDouble_(10.0)
        tell me to activate
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
        if theScript is not missing value then
            theScript's release()
        end if
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_

    -- utility methods -------------------------------------------------------------------------------
    on makeNSString(textString)
        return NSString's stringWithString_(textString)
    end makeNSString
    
    on displayInfo(infoMsg)
        tell me to activate
        setErrorColour_(NSColor's blackColor)
        setErrorMessage_(infoMsg)
        setErrorHidden_(false)
    end displayInfo
    
    on clearInfo()
        setErrorMessage_("")
        setErrorHidden_(true)
    end clearInfo
                
    on displayError(errMsg, isFatal)
        tell me to activate
        setErrorColour_(NSColor's systemRedColor)
        setErrorMessage_(errMsg)
        setErrorHidden_(false)
        
        if isFatal then
            setButtonName1_("OK")
        end if
    end displayError
    
    on timeToNumber(theHours, theMinutes)
        return (((theHours * 60) + theMinutes) * 60) as integer
    end timeToNumber
    
    on dateToNumber(theDate)
        return timeToNumber((theDate's hours) as integer, (theDate's minutes) as integer)
    end dateToNumber
    
    on timeStringToNumber(theHoursString, theMinutesString)
        set theHours to theHoursString as integer
        set theMinutes to theMinutesString as integer
        
        if theHours < 0 or theHours > 23 or theMinutes < 0 or theMinutes > 59 then
            return false
        end if
        
        return timeToNumber(theHours, theMinutes)
    end timeStringToNumber
    
    on formatTime(theTime, fullFormat)
        set theHours to theTime div hours
        set theTime to theTime mod hours
        set theMinutes to theTime div minutes
        set theResult to ""
        
        if theHours < 10 and fullFormat then
            set theResult to "0"
        end if
        
        set theResult to theResult & theHours & ":"
        
        if theMinutes < 10 then
            set theResult to theResult & "0"
        end if
        
        set theResult to theResult & theMinutes
        
        return theResult
    end formatTime
    
    -- application custom objects methods ------------------------------------------------------------
    on createScriptStep(actionType, pId, actionName, actionTime)
        script ScriptStep
            property stepType : missing value
            property postId : missing value
            property stepName : missing value
            property stepTimeInitial : missing value
            property stepTime : missing value
            property complete : missing value
            property status : missing value
            property checked : missing value
            
            on getType()
                return stepType
            end getType
            
            on getPostId()
                return postId
            end getPostId
                
            on getName()
                return stepName
            end getName
            
            on getOriginalTime()
                return stepTime as integer
            end getOriginalTime
            
            on getTime()
                return stepTime as integer
            end getTime
            
            on isComplete()
                return complete
            end isComplete
                
            on getStatus()
                return status
            end getStatus
            
            on isChecked()
                return checked
            end isChecked
            
            on setType(sType)
                set stepType to sType
            end setType
            
            on setPostId(sPostId)
                set postId to sPostId
            end setPostId
                
            on setName(sName)
                set stepName to sName
            end setName
            
            on setOriginalTime(sTime)
                set stepTime to sTime
            end setOriginalTime
            
            on setTime(sTime)
                set stepTime to sTime
            end setTime
            
            on setComplete_(sComplete)
                set complete to sComplete
            end setComplete_
            
            on setStatus_(sStatus)
                set status to sStatus
            end setStatus_
            
            on setChecked(sChecked)
                set checked to sChecked
            end setChecked
                
            on getFormattedName()
                return (getType() & ": " & getName()) as text
            end getFormattedName
                
            on clearChecked()
                set checked to false
            end clearChecked
                
            on markChecked()
                set checked to true
            end markChecked
        end script
        
        tell ScriptStep
            setType(actionType)
            setPostId(pId)
            setName(actionName)
            setOriginalTime(actionTime)
            setTime(actionTime)
            setComplete_(false)
            setStatus_("waiting")
            setChecked(false)
        end tell
        
        return ScriptStep
    end createScriptStep

    on createRect(rectData)
        script Rect
            property x : missing value
            property y : missing value
            property width : missing value
            property height : missing value

            on getLeft()
                return x
            end getLeft

            on getTop()
                return y
            end getTop

            on getRight()
                return x + width
            end getRight

            on getBottom()
                return y + height
            end getBottom

            on getWidth()
                return width
            end getWidth

            on getHeight()
                return height
            end getHeight

            on setLeft(l)
                set x to l
            end setLeft

            on setTop(t)
                set y to t
            end setTop

            on setWidth(w)
                set width to w
            end setWidth

            on setHeight(h)
                set height to h
            end setHeight
        end script

        if (class of rectData is not list) or (length of rectData is not 4) then
            return false
        end if

        tell Rect
            setLeft(item 1 of rectData)
            setTop(item 2 of rectData)
            setWidth(item 3 of rectData)
            setHeight(item 4 of rectData)
        end tell

        return Rect
    end createRect

    on createPost(postData)
        script Post
            property postId : missing value
            property title : missing value
            property textContents : missing value
            property postRect : missing value

            on getPostId()
                return postId
            end getPostId

            on getTitle()
                return title
            end getTitle

            on getContents()
                return textContents
            end getContents

            on getRect()
                return postRect
            end getRect

            on setPostId(pId)
                set postId to pId
            end setPostId

            on setTitle(pTitle)
                set title to pTitle
            end setTitle

            on setContents(pContents)
                set textContents to pContents
            end setContents

            on setRect(pRect)
                set postRect to pRect
            end setRect
        end script

        if (class of postData is not list) or (length of postData is not 4) then
            return false
        end if

        tell Post
            setPostId(item 1 of postData)
            setTitle(item 2 of postData)
            setContents(item 3 of postData)

            set pRect to createRect(item 4 of postData)
            setRect(pRect)
        end tell

        return Post
    end createPost

    on createSection(sId, sTitle)
        script Section
            property sectId : missing value
            property title : missing value
            property posts : {}

            on getSectionId()
                return sectId
            end getSectionId

            on getTitle()
                return title
            end getTitle

            on getPosts()
                return posts
            end getPosts

            on setSectionId(sId)
                set sectId to sId
            end setSectionId

            on setTitle(sTitle)
                set title to sTitle
            end setTitle

            on addPost(Post)
                set the end of posts to Post
            end addPost
        end script

        tell Section
            setSectionId(sId)
            setTitle(sTitle)
        end tell

        return Section
    end createSection

    -- interface with Safari methods -----------------------------------------------------------------
    on runJavaScript(jScript, doc, returnType)
        set theResult to missing value
        try
            tell application "Safari"
                set theResult to do JavaScript jScript in doc
            end tell
            
            if theResult is missing value then
                return false
            end if
            
            if the class of theResult is returnType then
                return theResult
            else
                return false
            end if
        on error errMsg number errorNumber
            if errorNumber is -2753 then
                -- trap occasions when a script returns no value
                return false
            else
                return false
            end if
        end try

    end runJavaScript

    on focusTab(tabName)
        tell application "Safari"
            set win to the first window
            repeat with thisTab in the tabs of win
                if the name of thisTab is tabName or (tabName is "dashboard" and the name of thisTab starts with "Dashboard") then
                    set the current tab of win to thisTab
                    exit repeat
                end if
            end repeat
        end tell
    end focusTab
                    
    -- methods to extract data drom Padlet -----------------------------------------------------------
    on getPadletType(doc)
        set padletType to runJavaScript(padletTypeScript, doc, text)
        
        if padletType is false or padletType is "unknown" then
            error "Couldn't determine the type of the padlet." number 501
        end if
        
        if padletTypes does not contain padletType then
            error "The padlet is a " & padletType & " padlet which is not supported at present." number 502
        end if
        
        return padletType
    end getPadletType

    on getControlDoc()
        set topDoc to missing value
        set pageUrl to ""

        tell application "Safari"
            set topDoc to document 1
            set pageUrl to the URL of topDoc
        end tell

        if pageUrl does not start with "https://padlet.com/" then
            error "The frontmost Safari window isn't a Padlet document. Open the appropriate main administrator's Padlet and ensure that it is the front window.  Then run the script again." number 503
        end if

        set controlType to getPadletType(topDoc)

        if controlType is "unknown" then
            error "Couldn't determine the type of padlet. Ensure that the top window isn't the Padlet dashboard page." number 504
        else if controlType is not "canvas" then
            error "This isn't a canvas padlet. Ensure that the top window is the Control Padlet which must be a canvas padlet." number 505
        end if
        
        set controlDoc to topDoc
    end getControlDoc

    on getDoc(docName, docType)
        tell application "Safari"
            repeat with win in (every window where visible is true)
                set tabCount to number of tabs in win
                repeat with j from 1 to tabCount
                    set tabDoc to tab j of win
                    ignoring case
                        if the name of tabDoc is docName then
                            return tabDoc
                        end if
                    end ignoring
                end repeat
            end repeat
        end tell

        if docType = 0 then
            return false
        end if
        
        set js to regex change getDocScript search pattern "@docName@" replace template docName
        
        set success to runJavaScript(js, dashboardDoc, boolean)
        if success is true then
            set doc to missing value
            tell application "Safari"
                set doc to current tab of window 1
            end tell
            return doc
        end if
        
        return false
    end getDoc

    on getShelfPosts(doc)
        set sectionsList to runJavaScript(shelfPostsScript, doc, list)
        set sections to {}
        
        repeat with sectionData in sectionsList
            if the class of sectionData is list and the length of sectionData ≥ 3 and the class of item 3 of sectionData is list then
                set sect to createSection(item 1 of sectionData, item 2 of sectionData)
                
                repeat with pData in item 3 of sectionData
                    set pst to createPost(pData)
                    tell sect
                        addPost(pst)
                    end tell
                end repeat
                
                set the end of sections to sect
            end if
        end repeat

        return sections
    end getShelfPosts
                
    on getPosts(doc, docType)
        if docType is "shelf" then
            return getShelfPosts(doc)
        end if
        
        set js to ""
        
        if docType is "canvas" then
            set js to canvasPostsScript
        else if docType is "map" then
            set js to mapPostsScript
        else if docType is "timeline" then
            set js to timelinePostsScript
        end if

        set postList to runJavaScript(js, doc, list)

        if postList is false then
            error "Encountered problem retrieving the posts from Padlet." number 506
        end if
        
        set posts to {}

        repeat with pData in postList
            set pst to createPost(pData)
            set the end of posts to pst
        end repeat

        return posts
    end getPosts

    on getPostId(postName)
        repeat with post in sourcePosts
            ignoring case
                if post's getTitle() is postName then
                    return post's getPostId()
                end if
            end ignoring
        end repeat
        return false
    end getPostId
    
    -- script setup methods --------------------------------------------------------------------------
    on fetchScript()
        displayInfo("Locating control padlet")
        getControlDoc()
        
        displayInfo("Locating padlet dashboard")
        set doc to getDoc("Dashboard | Padlet", 0)
        if doc is false then
            error "Can't locate dashboard" number 509
        end if
        set dashboardDoc to doc
        
        displayInfo("Reading control padlet")
        set cPosts to getPosts(controlDoc, "canvas")
        if (cPosts is false) or (cPosts's length is 0) then
            error "No script posts were found" number 508
        end if
        
        set controlPosts to cPosts
        set scriptPost to item 1 of controlPosts
        set scriptText to scriptPost's getContents()
        set scriptList to {}

        set errMsg to {}
        set scriptPattern to "^\\s*(\\S+):\\s+((?=.+at \\d)(.+)\\s+at\\s+(\\d\\d?):(\\d\\d)|(.+))\\s*$"
        
        displayInfo("Parsing script")
        repeat with scriptLine in every paragraph of scriptText
            if length of scriptLine > 0 then
                set parsedStep to regex search scriptLine search pattern scriptPattern capture groups {1, 3, 4, 5, 6}
                set postId to ""
                set actionName to false
                set actionValue to false
                set actionTime to 0
                
                if length of parsedStep is 0 then
                    set the end of errMsg to "Can't understand script line: " & scriptLine
                else
                    set parsedStep to item 1 of parsedStep
                    set actionName to lowercase from ((item 1 of parsedStep) as text)
                    
                    if actionName is "source" or actionName is "target" then
                        set actionValue to (item 5 of parsedStep) as text
                    else
                        set actionValue to (item 2 of parsedStep) as text
                        set actionHours to (item 3 of parsedStep) as text
                        set actionMinutes to (item 4 of parsedStep) as text
                        set actionTime to timeStringToNumber(actionHours, actionMinutes)

                        if actionTime is false then
                            set the end of errMsg to actionHours & ":" & actionMinutes & " isn't a valid time"
                        end if
                    end if
                end if
                
                if actionName is not false and actionValue is not false and actionTime is not false then
                    if actionName is "source" then
                        setSourceName_(makeNSString(actionValue))
                    else if actionName is "target" then
                        setTargetName_(makeNSString(actionValue))
                    else if actionName is "copy" then
                        set the end of scriptList to {actionName, actionValue, actionTime}
                    else
                        set the end of errMsg to "Action " & actionName & " is not recognised"
                    end if
                end if
            end if
        end repeat

        set sourceType to ""
        
        displayInfo("Checking source padlet")

        if sourceName is missing value then
            set the end of errMsg to "No source identified in the script"
        else
            set doc to getDoc(sourceName as text, 1)
            if doc is false then
                set the end of errMsg to "Couldn't find source padlet: " & sourceName
            else
                set sourceDoc to doc
                delay 2
                
                set sourceType to getPadletType(sourceDoc)
                if sourceType is not false then
                    set sourcePosts to getPosts(sourceDoc, sourceType)
                    if sourcePosts's length is 0 then
                        set the end of errMsg to "No posts were found in the source padlet."
                    end if
                else
                    set the end of errMsg to "Couldn't determine the format of the source padlet."
                end if
            end if
        end if

        displayInfo("Checking target padlet")
        if targetName is missing value then
            set the end of errMsg to "No target identified in the script."
        else
            set doc to getDoc(targetName as text, 1)
            if doc is false then
                set the end of errMsg to "Couldn't find target padlet: " & targetName
            else
                set targetDoc to doc
                delay 2
                
                set targetType to getPadletType(targetDoc)
                if targetType is false then
                    set the end of errMsg to "Couldn't determine the format of the target padlet."
                else if targetType is not sourceType then
                    set the end of errMsg to "The target and source padlets are of different types."
                else
                    set targetPosts to getPosts(targetDoc, sourceType)
                end if
            end if
        end if
        
        repeat with scriptItem in scriptList
            set actionType to item 1 of scriptItem
            set actionName to item 2 of scriptItem
            set actionTime to item 3 of scriptItem
            set postId to missing value
            
            if actionName is not missing value then
                set postId to getPostId(actionName)
            end if
            
            if postId is missing value or postId is false then
                set the end of errMsg to "Can't find post: '" & actionName & "'"
            else
                set scriptStep to createScriptStep(actionType, postId, actionName, actionTime)
                theScript's addObject_(scriptStep)
            end if
        end repeat
        
        if the length of errMsg > 0 then
            set errorText to ""
            
            repeat with i from 1 to errMsg's length
                if i is 1 then
                    set errorText to (item 1 of errMsg) as text
                else
                    set errorText to errorText & "\n" & (item 1 of errMsg) as text
                end if
            end repeat
            
            error errorText number 507
        end if
    end fetchScript

    on loadScript()
--        try
            setButtonName1_("Loading...")
            fetchScript()
            tell me to activate
            setErrorHidden_(true)
            setStartTimeDisplay_("waiting...")
            setButtonName1_("Run script")
            setButtonName2_("Copy items now")
            setButtonName3_("Remove items")
            setButtonName4_("Quit")
            setButtonHidden3_(false)
            setButtonHidden4_(false)
            setCheckboxHidden_(false)
            theTableView's reloadData()
--        on error errorMessage
--            displayError(errorMessage, true)
--        end try
    end loadScript
    
    -- script actions methods ------------------------------------------------------------------------
    on fetchPostIds(doc)
        set postIds to runJavascript(fetchPostIdsScript, doc, list)
        return postIds
    end fetchPostIds
    
    on activateEdit(doc, postId)
        set activateEditAttr to "'" & postId & "'"
        set js to regex change activateEditScript search pattern "@activateEditAttr@" replace template activateEditAttr
        set success to runJavaScript(js, doc, boolean)
        return success
    end activateEdit
    
    on activateDuplicate(doc)
        set success to runJavaScript(activateDuplicateScript, doc, boolean)
        return success
    end activateDuplicate
    
    on activateDeletePost(doc)
        set success to runJavaScript(activateDeleteScript, doc, boolean)
        return success
    end activateDeletePost
    
    on deletePost()
        set success to runJavaScript(deletePostScript, doc, boolean)
        return success
    end deletePost
    
    on selectTarget(doc)
        set selectTargetAttr to "'" & targetName & "'"
        set js to regex change selectTargetScript search pattern "@selectTargetAttr@" replace template selectTargetAttr
        set success to runJavaScript(js, doc, boolean)
        return success
    end selectTarget
    
    on fetchPostId(doc, postTitle)
        set fetchPostIdAttr to "'" & postTitle & "'"
        set js to regex change fetchPostIdScript search pattern "@fetchPostIdAttr@" replace template fetchPostIdAttr
        set counter to 0
        repeat while counter < 3
            delay 2

            set counter to counter + 1
            set postId to runJavaScript(js, doc, text)
            
            if postId is not false and (count postId) > 0 then
                return postId
            end if
        end repeat
        
        return "[not found]"
    end fetchPostId
    
    on moveResizePost(doc, targetPostId, postRect)
        set moveResizePostAttr to "'" & targetPostId & "', " & postRect's getLeft() & ", " & postRect's getTop() & ", " & postRect's getWidth() & ", " & postRect's getHeight()
        set js to regex change moveResizePostScript search pattern "@moveResizePostAttr@" replace template moveResizePostAttr
        set theResult to (runJavaScript(js, doc, number)) as integer
        
        return theResult
    end moveResizePost
    
    on clearTargetPadlet()
        displayInfo("Clearing target padlet")
        
        set postIds to fetchPostIds(targetDoc)
        
        if postIds is false then
            displayError("Failed to delete posts from target Padlet", false)
            return false
        end if

        set errMsgs to {}
        repeat with postId in postIds
            delay 2
            
            set success to activateEdit(targetDoc, postId)
            
            if not success then
                set the end of errMsgs to "Couldn't locate the edit button for post: \"" & postId & "\""
            else
                delay 2

                set success to activateEdit(targetDoc, postId)

                if not success then
                    set the end of errMsgs to "Couldn't locate the delete poat button for post: \"" & postId & "\""
                else
                    delay 2
                    
                    set success to deletePost(targetDoc)
                    
                    if success is false then
                        set the end of errMsgs to "Couldn't delete the poat: \"" & postId & "\""
                    end if
                end if
            end if
        end repeat
        
        if count errMsgs > 0 then
            set errorMessage to ""
            set n to 0
            
            repeat with errMsg in errMsgs
                set n to n + 1
                if n is 1 then
                    set errorMessage to errMsg
                else
                    set errorMessage to errorMessage & "\n" & errMsg
                end if
            end repeat
            
            displayError(errorMessage, false)
        end if
    end clearTargetPadlet
    
    on copyCanvasPost(post)
        try
            set postTitle to post's getTitle()
            
            set success to activateEdit(sourceDoc, post's getPostId())
            
            if not success then
                displayError("Couldn't locate the edit button for post: \"" & postTitle & "\"", false)
                return false
            end if
            
            delay 2
            
            set success to activateDuplicate(sourceDoc)
            
            if not success then
                displayError("Couldn't locate the duplicate button for post: \"" & postTitle & "\"", false)
                return false
            end if
            
            delay 2
            
            set success to selectTarget(sourceDoc)

            if not success then
                displayError("Couldn't locate the target padlet: \"" & targetName & "\" in the list.", false)
                return false
            end if
            
            set targetPostId to fetchPostId(targetDoc, postTitle)
            
            if targetPostId is "[not found]" then
                displayError("Unable to locate post: \"" & postTitle & "\" in target padelet: \"" & targetName & "\"", false)
                return false
            end if

            set theResult to moveResizePost(targetDoc, targetPostId, post's getRect())

            if theResult is -1 then
                displayError("Couldn't locate the post: \"" & postTitle & "\" in the target padlet: \"" & targetName & "\".", false)
                return false
            else if theResult is -2 then
                displayError("Couldn't move the post: \"" & postTitle & "\" in the target padlet: \"" & targetName & "\".", false)
            else if theResult is -3 then
                displayError("Couldn't resize the post: \"" & postTitle & "\" in the target padlet: \"" & targetName & "\".", false)
            end if
            
            return true
        on error errorMessage
            log errorMessage
            return false
        end try
    end copyCanvasPost
    
    on copyPost(post)
        displayInfo("Copying post: \"" & post's getTitle() & "\"")
        set success to false
        if sourceType as text is "canvas" then
            set success to copyCanvasPost(post)
        end if
        
        return success
    end copyPost
    
    -- script run methods ----------------------------------------------------------------------------
    on performAction(stepIndex)
        set scriptStep to theScript's objectAtIndex_(NSNumber 's numberWithInt_(stepIndex))
        set postId to scriptStep's getPostId() as text
        set actionType to scriptStep's getType()
        set actionStatus to ""

        set post to missing value
        repeat with thisPost in sourcePosts
            set thisPostId to thisPost's getPostId() as text
            if thisPost's getPostId() is postId then
                set post to thisPost
                exit repeat
            end if
        end repeat
        
        if post is missing value then
            set actionStatus to "Not found"
        else
            scriptStep's setStatus_("copying...")
            theTableView's reloadData()
            
            set success to false
            ignoring case
                if actionType as text is "copy" then
                    set success to copyPost(post)
                end if
            end ignoring
            
            if success is true then
                set actionStatus to "Copied"
                clearInfo()
            else
                set actionStatus to "Error"
            end if
        end if
        
        scriptStep's setStatus_(actionStatus)
        scriptStep's setComplete_(true)
        theTableView's reloadData()
    end performAction
    
    on tick_(sender)
        try
            set now to current date
            set thisTime to dateToNumber(now)
            if paused is true then
                set currentPause to pauseDuration + thisTime - pauseTime + 1
                setPauseDisplay_(currentPause as text & " min")
            else
                set scriptComplete to true

                repeat with i from 0 to theScript's |count|() - 1
                    set step to theScript's objectAtIndex_(NSNumber's numberWithInt_(i))
                    set stepTime to (startTime as integer) + (step's getTime() as integer)
                    set stepComplete to (step's isComplete() as integer) = 1

                    if not stepComplete then
                        if thisTime >= stepTime then
                            performAction(i)
                        else
                            set scriptComplete to false
                        end if
                    end if
                end repeat
                
                if scriptComplete is true then
                    setStartTimeDisplay_("complete")
                    theTimer's invalidate()
                    setTheTimer_(missing value)
                    displayInfo("Script complete")
                end if
            end if
        on error errorMessage
            displayError(errorMessage, false)
        end try
    end tick_
    
    on startTimer()
        setTheTimer_(MyTimer's timerWithInterval_target_selectorName_(10.0, me, "tick:"))
    end startTimer
        
    on runScript()
        try
            if clearTarget is true then
                clearTargetPadlet()
            end if
            
            set now to current date
            set startTime to dateToNumber(now)
            setStartTimeDisplay_(formatTime(startTime, true))
            setButtonName1_("Pause script")
            setIsRunning_(true)
            theTableView's reloadData()
            startTimer()
            displayInfo("Running")
        on error errorMessage
            displayError(errorMessage, true)
        end try
    end runScript
    
    on pauseScript()
        try
            setPaused_(true)
            if pauseHidden is true then
                setPauseHidden_(false)
                setPauseDisplay_("0 min")
            end if
            
            set now to current date
            set pauseTime to dateToNumber(now)
            setButtonName1_("Restart script")
        on error errorMessage
            displayError(errorMessage, false)
        end try
    end pauseScript
    
    on restartScript()
        try
            set now to current date
            set pauseEnd to dateToNumber(now)
            setPauseDuration_(pauseDuration + pauseEnd - pauseTime)

            if pauseDuration as integer is 0 then
                setPauseHidden_(true)
            else
                setPauseDisplay_(pauseDuration as text & " min")
                repeat with step in theScript
                    if step's isComplete() as integer is 0 then
                        set stepTime to (step's getOriginalTime() + pauseDuration) as integer
                        step's setTime(stepTime)
                    end if
                end repeat
                theTableView's reloadData()
            end if
            
            setButtonName1_("Pause script")
            setPaused_(false)
        on error errorMessage
            displayError(errorMessage, false)
        end try
    end restartScript
    
    -- interface action handlers ---------------------------------------------------------------------
    on buttonClick1_(sender)
        if (buttonName1 as text) is "Load script" then
            loadScript()
        else if (buttonName1 as text) is "Run script" then
            runScript()
        else if (buttonName1 as text) is "Pause script" then
            pauseScript()
        else if (buttonName1 as text) is "Restart script" then
            restartScript()
        else if (buttonName1 as text) is "OK" then
            quit
        end if
    end buttonClick1_
    
    on buttonClick2_(sender)
        if (buttonName2 as text) is "Cancel" then
            quit
        end if
    end buttonClick2_
    
    on buttonClick3_(sender)
        
    end buttonClick3_
    
    on buttonClick4_(sender)
        quit
    end buttonClick4_

    on clickedCheckBox_(sender)
        set rowIndex to theTableView's rowForView_(sender)
        set step to theScript's objectAtIndex_(rowIndex)
        set stepChecked to false
        if (sender's state) is 0 then
            set stepChecked to true
        end if
        
        if stepChecked then
            step's markChecked()
        else
            step's clearChecked()
        end if
    end clickedCheckBox_

    on clickedClearCheckbox_(sender)
        set clear to false
        if (sender's state) is 0 then
            set clear to true
        end if

        setClearTarget_(clear)
    end clickedClearCheckbox_
    
    -- script table view methods ---------------------------------------------------------------------
    on tableView_viewForTableColumn_row_(theTableView, theColumn, theRow)
        set step to theScript's objectAtIndex_(theRow)
        set colIdent to (theColumn's identifier) as text
        set fieldString to regex change colIdent search pattern "Col$" replace template "Cell"
        set fieldIdent to makeNSString(fieldString)
        set theField to theTableView's makeViewWithIdentifier_owner_(fieldIdent, me)

        if colIdent is "actionCol" then
            set checkedState to 0

            if step's isChecked() then
                set checkedState to 1
            end if

            set theCheckBox to (theField's checkbox)
            set theCheckBox's title to step's getFormattedName()
            theCheckBox's setState_(checkedState)
        else
            set fieldText to ""

            if colIdent is "timeCol" then
                set stepTime to step's getTime() as integer

                if isRunning then
                    set stepTime to stepTime + (startTime as integer) + (pauseTime as integer)
                    set fieldText to formatTime(stepTime, true)
                else
                    set fieldText to "+" & formatTime(stepTime, false)
                end if
            else if colIdent is "statusCol" then
                set fieldText to step's getStatus()
            else
                set fieldText to "[Unknown]"
            end if

            set theField's textField's stringValue to makeNSString(fieldText)
        end if

        return theField
    end tableView_viewForTableColumn_row_
    
    on numberOfRowsInTableView_(theTableView)
        if theScript is missing value then
            return 0
        end if
        
        return theScript's |count|()
    end numberOfRowsInTableView_
    
end script
