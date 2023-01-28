function gmsh_reader(filename::String,internal_field_name::String="fluid")
    names = String[]
    bc_tags = Int64[]
    BC_nodes = []
    elem_type = Int64[]
    fluid_tag = 0
    crds = zeros(1,3)
    face = []
    conn = []
    f = open(filename,"r")
    lines = readlines(f)
    for i = 1:size(lines,1)
        ln = lines[i]
        if ln == "\$PhysicalNames"
            ln = lines[i+1]
            nNames = parse.(Int64,ln)
            nNames = nNames[1]
            for j = 1:nNames
                ln = lines[i+1+j]
                ln = split(ln)
                push!(bc_tags,parse(Int64,ln[2]))
                push!(names,chop(ln[3],head=1,tail=1)) 
            end
            fluid_tag = bc_tags[findfirst(==(internal_field_name),names)]
            BC_nodes = [[] for k = 1:nNames]
        end
        if ln == "\$Nodes"
            ln = lines[i+1]
            ncrd = parse.(Int64,ln)
            ncrd = ncrd[1]
            crds = zeros(ncrd,3)
            for j = 1:ncrd
                ln = lines[i+1+j]
                ln = parse.(Float64,split(ln))
                crds[j,:] .= ln[2:4]
            end
        end
        if ln == "\$Elements"
            ln = lines[i+1]
            nelem = parse.(Int64,ln)
            nelem = nelem[1]
            for j = 1:nelem
                ln = lines[i+1+j]
                ln = split(ln)
                ln = parse.(Int64,ln)
                if ln[4] != fluid_tag
                    r = findfirst(==(ln[4]),bc_tags)
                    for k = 6:size(ln,1)
                        push!(BC_nodes[r],ln[k])
                    end
                else
                    push!(elem_type,ln[2])
                    push!(conn,ln[6:end])
                end
            end
        end
    end
    close(f)
    conn = Matrix(reduce(hcat,conn)')
    return names,bc_tags,crds,elem_type,BC_nodes,conn
end

