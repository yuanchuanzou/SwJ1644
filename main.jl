#t = randn(100)
#y = randn(100)
using CSV 
df = CSV.read("lc.csv")
using DataFrames
df2 = sort!(df)
t = convert(Array{Float64},df2[1])
y = convert(Array{Float64},df2[4])

N = length(t)
jPeak = 1
jDip = 1
ratio = 1.005
flag = "Dip"
Peak = ones(N,2) # 1 for t, 2 for y
Dip = ones(N,2)
PeakTmp = ones(N,2)
DipTmp = ones(N,2)
PeakTmp[jPeak,1:2] = [t[1],y[1]]
DipTmp[jDip,:] = [t[1],y[1]]
Peak[jPeak,:] = [t[1],y[1]]
for i in 2:N
    if y[i] > y[i-1]
        if y[i] > PeakTmp[jPeak,2]
            PeakTmp[jPeak,:] = [t[i],y[i]]
            println("PeakTmp[jPeak,:]", PeakTmp[jPeak,:], " y[i]: ", y[i], " y[i-1]: ", y[i-1])
        end
#        if flag == "Dip"
#            DipTmp[jDip,:] = [t[i],y[i]]
            #println(DipTmp[jDip,:])
#        end
        if flag == "Peak"
            println("Now in peak")
            if PeakTmp[jPeak,2]/ratio > DipTmp[jDip,2]
                Dip[jDip,1:2] = DipTmp[jDip,1:2]
                jDip = jDip + 1
                println("jDip:", jDip)
                flag = "Dip"
                DipTmp[jDip,:] = [t[i],y[i]]
            end
        end
    end
    if y[i] < y[i-1]
        if y[i] < DipTmp[jDip,2]
            DipTmp[jDip,:] = [t[i],y[i]]
            println("DipTmp[jDip,:] ", DipTmp[jDip,:], " y[i]: ", y[i], " y[i-1]: ", y[i-1])
        end
#        if flag == "Peak"
#            PeakTmp[jPeak,:] = [t[i],y[i]]
#            println("Now in Peak 2, PeakTmp:", PeakTmp[jPeak,:])
#        end
        if flag == "Dip"
            println(i, " Now in Dip 2, PeakTmp: ", PeakTmp[jPeak,2],", DipTmp:", DipTmp[jDip,2])
            if PeakTmp[jPeak,2]/ratio > DipTmp[jDip,2]
                Peak[jPeak,1:2] = PeakTmp[jPeak,1:2]
                jPeak = jPeak + 1
                println("jPeak:", jPeak)
                flag = "Peak"
                PeakTmp[jPeak,:] = [t[i],y[i]]
            end
        end
    end
end
Peak2 = ones(jPeak,2)
for i=1:jPeak
    Peak2[i,:] = Peak[i,:]
end
Peaks = Peak2
