using SwJ1644
using CSV 

#df = ReadData("../lc.csv")
df = CSV.read("../lc.csv")
#@show data 

#plotlc(data)
using DataFrames
#using Test

df2 = sort!(df)
#@show plot(df2[1],df2[4])
#A1 = convert(Array,df2)
t = convert(Array{Float64},df2[1])
y = convert(Array{Float64},df2[4])
#Peaks = peaks(t,y)
Peaks = peaks2(t,y)

#=
#beging Test


N = length(t)
jPeak = 1
jDip = 1
ratio = 1.01
flag = "Dip"
Peak = ones(N,2) # 1 for t, 2 for y
Dip = Peak
PeakTmp = Peak
DipTmp = Peak
PeakTmp[jPeak,1:2] = [t[1],y[1]]
DipTmp[jDip,:] = PeakTmp[1,:]
for i=1:N
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
            PeakTmp[jDip,:] = [t[i],y[i]]
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

Peaks = Peak2


#end Test

=#


N = Int64(length(Peaks)/ndims(Peaks))
tPeaks1 = Peaks[:,1]
tPeaks2 = ones(N-1) #initialize an array
DeltatPeak = ones(N-1) #initialize an array
for i=1:N-1
    tPeaks2[i] = (tPeaks1[i+1]+tPeaks1[i])/2
    DeltatPeak[i] = tPeaks1[i+1]-tPeaks1[i]
end

#= using Plots
#using Gadfly
#plot(tPeaks2,DeltatPeak)
plot(log10.(tPeaks2),log10.(DeltatPeak))
savefig("fig.png")
=#

# To plot the period-t diagram
using RCall
@rlibrary ggplot2
dat = DataFrame(tP=tPeaks2, DP=DeltatPeak)
p = ggplot(data=dat, aes(x=log10.(dat[:tP]), y=log10.(dat[:DP])))
p = p + geom_point(size=2)
#print(p)
ggsave(file="Period-t.eps")

# To plot the light curves and the peaks are emphersized
tt = DataFrame(t=t, y=y)
dfPeaks = DataFrame(t=Peaks[:,1], p=Peaks[:,2])
p = ggplot(data=dfPeaks, aes(x=dfPeaks[:t],y=dfPeaks[:p]))
#p = ggplot(data=DataFrame(x=t,y=y),aes(x=:x,y=:y))
#p = ggplot(data=DataFrame(x=df2[1],y=df2[4])),aes(x=:x,y=:y)
p = p + geom_point(size=2,color="red")
#p = p + geom_point(aes(x=:df2[1],y=:df2[4]),size=2,color="grey")
#p = p + geom_point(aes(x=tPeaks2,y=DeltatPeak),size=2,color="grey")
#p = p + geom_point(aes(x=tt[:t],y=tt[:y]),size=2,color="grey")
p = p + layer(
    data=tt, geom="point", stat="identity", position="identity", 
    mapping = aes(x=tt[:t], y=tt[:y])
)
#p = p + geom_point(size=1, color="grey")
p = p + scale_x_log10() + scale_y_log10()
print(p)
ggsave(file="light-curves.eps")
#p = ggplot(data=df2,aes(x=dat[:tP],y=dat[:DP]))
