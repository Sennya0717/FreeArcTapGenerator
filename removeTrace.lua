Macro.new("sennya")
    .withName("Sennya's macros")
    .withIcon("f1b7")
    .add()

Macro.new("removeTrace")
    .withName("Remove Trace")
    .withIcon("e9e9")
    .withParent("sennya")
    .withDefinition(function()
        local selected = Event.getCurrentSelection(EventSelectionConstraint.create().voidArc())
        if selected == {} then
            notifyWarn("Please choose atleast 1 trace")
        end
        local allArctaps = Event.query(EventSelectionConstraint.create().arctap())

        local command = Command.create("Selected Trace(s) Removed")
        local arcs = {}

        --列出所有選擇的黑線
        local traces = {}
        for _, trace in ipairs(selected.resultCombined) do
            table.insert(traces, trace)
            command.add(trace.delete())
        end
        
        --重寫黑線、天鍵
        for _, arctap in ipairs(allArctaps.arctap) do
            for _, trace in ipairs(traces) do
                if arctap.arc.instanceEquals(trace) then
                    local timing = arctap.timing
                    table.insert(arcs, Event.arc(
                    timing, arctap.arc.positionAt(timing),
                    timing+1, arctap.arc.positionAt(timing),
                    true, 0, "s", arctap.timingGroup
                    ))
                    command.add(arcs[#arcs].save())
                    command.add(Event.arctap(timing, arcs[#arcs], 1).save())
                    command.add(arctap.delete())
                end
            end
        end
        command.commit()
    end)
    .add()