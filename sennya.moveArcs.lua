Macro.new("moveArcs")
    .withName("Move Arcs")
    .withIcon("e89f")
    .withParent("sennya")
    .withDefinition(function()
        local selected = Event.getCurrentSelection(EventSelectionConstraint.create().arc())
        if #selected.resultCombined == 0 then
            notifyWarn("Please choose atleast 1 arc/trace")
            return
        end

        local FieldX = DialogField.create("X")
            .setLabel("X")
            .defaultTo(0)
            .textField(FieldConstraint.create().float())
            .setHint("X-axis movement distance...")
        local FieldY = DialogField.create("Y")
            .setLabel("Y")
            .defaultTo(0)
            .textField(FieldConstraint.create().float())
            .setHint("Y-axis movement distance...")        
        
        local userInput = 
            DialogInput
                .withTitle("Move Arcs")
                .requestInput({
                    FieldX,
                    FieldY
                })
        coroutine.yield()

        local x = tonumber(userInput.result["X"])
        local y = tonumber(userInput.result["Y"])

        local allArctaps = Event.query(EventSelectionConstraint.create().arctap())

        local command = Command.create("Moved Arcs")
        local arcs = {}
        local traces = {}
        local newTraces = {}

        for _, object in ipairs(selected.resultCombined) do
            table.insert(arcs, Event.arc(
                object.timing, object.startX + x, object.startY + y,
                object.endTiming, object.endX + x, object.endY + y,
                object.isVoid, object.color, object.type, object.timingGroup, object.sfx, object.arcResolutionMultiplier))

            if object.is("voidarc") then
                table.insert(traces, object)
                table.insert(newTraces, arcs[#arcs])
            end
            command.add(arcs[#arcs].save())
            command.add(object.delete())
        end
        for _, arctap in ipairs(allArctaps.arctap) do
            for traceIndex, trace in ipairs(traces) do
                if arctap.arc.instanceEquals(trace) then
                    command.add(Event.arctap(arctap.timing,newTraces[1] , arctap.width).save())
                    command.add(arctap.delete())
                end
            end
        end
        command.commit()
    end)
    .add()