; Macro per inserire un oggetto calcolando l'ID della stanza a tempo di compilazione dall'offset in RoomsListTable
    MACRO ITEM room_sublabel, x, y, color, state
        db (room_sublabel - RoomsListTable) / 2, x, y, color, state
    ENDM


    MACRO ROOM room_sublabel
        db (room_sublabel - RoomsListTable) / 2
    ENDM