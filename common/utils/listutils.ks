
Global Function FindInList { 
    Parameter theList.
    Parameter predicate. 

    Local match to "None".

    For item in theList { 
        If predicate:Call(item) { 
            Set match to item.
            Break.
        }
    }

    Return match.
}