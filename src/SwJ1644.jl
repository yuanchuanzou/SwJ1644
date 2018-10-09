module SwJ1644

#Example
export greet
greet() = print("Hello World!")

# input and output
using CSV
#using FileIO

export ReadData
function ReadData(filename::String)
    data = CSV.read(filename)
    #data = load(filename)
    return data 
end

# To find peaks from the light curve
export peaks
function peaks(t,y)
    N = length(t)
    j = 0
    Peak = ones(N,2)
    for i=4:N-3
        if (max(y[i+1],y[i+2],y[i+3])<y[i]) 
            if (max(y[i-1],y[i-2],y[i-3])<y[i])
                j=j+1
                Peak[j,1]=t[i]
                Peak[j,2]=y[i]
            end
        end
#        if j>3
#            if (Peak[j,1]-Peak[j-1,1])<2*(Peak[j-1,1]-Peak[j-2,1])
#                j=j-1
#            end
#        end
    end
    Peak2 = ones(j,2)
    for i=1:j
        Peak2[i,1] = Peak[i,1]
        Peak2[i,2] = Peak[i,2]
    end
    return Peak2
end

# another method to find the peaks and also the dips
export peaks2
function peaks2(t,y)
    N = length(t)
    jPeak = 1
    jDip = 1
    ratio = 1.01
    flag = "Dip"
    Peak = ones(N,2) # 1 for t, 2 for y
    Dip = Peak
    PeakTmp = Peak
    DipTmp = Peak
    PeakTmp[1,1:2] = [t[1],y[1]]
    DipTmp[1,:] = PeakTmp[1,:]
    for i in 1:N
        if y[i] > PeakTmp[jPeak,2]
            PeakTmp[jPeak,:] = [t[i],y[i]]
            if flag == "Dip"
                DipTmp[jDip,:] = [t[i],y[i]]
            end
            if flag == "Peak"
                if PeakTmp[jPeak,2]/ratio > DipTmp[jDip,2]
                    Dip[jDip,1:2] = DipTmp[jDip,1:2]
                    jDip = jDip + 1
                    flag = "Dip"
                    DipTmp[jDip,:] = [t[i],y[i]]
                end
            end
        end
        if y[i] < DipTmp[jDip,2]
            DipTmp[jDip,:] = [t[i],y[i]]
            if flag == "Peak"
                PeakTmp[jPeak,:] = [t[i],y[i]]
            end
            if flag == "Dip"
                if PeakTmp[jPeak,2]/ratio > DipTmp[jDip,2]
                    Peak[jPeak,1:2] = PeakTmp[jPeak,1:2]
                    jPeak = jPeak + 1
                    flag = "Peak"
                    PeakTmp[jPeak,:] = [t[i],y[i]]
                end
            end
        end
    end
    # cut the ends of the Peak
    Peak2 = ones(jPeak,2)
    for i=1:jPeak
        Peak2[i,:] = Peak[i,:]
    end
    return Peak2
    # can also return Dips
end

# plot 
#using Plots
# export plotlc
function plotlc(x::Array,y::Array)
    plot(x,y)
end

end # module
