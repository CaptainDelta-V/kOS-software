// Friendly identifier for a docking port: Tag if set, else the parent part's Title,
// else "#<UID>" as a last resort.
Global Function DockingPortDisplayName {
    Parameter port.
    If port:Tag <> "" {
        Return port:Tag.
    }
    If port:HasParent {
        Return port:Parent:Title.
    }
    Return "#" + port:UID.
}
