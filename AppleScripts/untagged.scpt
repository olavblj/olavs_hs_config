tell application "Things3"
    set newTags to "/untagged"

    repeat with toDo in to dos
        set oldTags to tag names of toDo
        set numTags to items of oldTags
        set countTags to number of items in numTags
        if countTags = 0 then set tag names of toDo to newTags
    end repeat

    repeat with pr in projects
    	set tag names of pr to ""
    end repeat
end tell