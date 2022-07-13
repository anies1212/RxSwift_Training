import UIKit
import RxSwift
import RxCocoa


//MARK: -1つのObjectとして呼ばれる.
let obersevable = Observable.just(1)
let observable2 = Observable.of(1,2,3)
let observable3 = Observable.of([1,2,3])

//MARK: -別々のObjectとしてmapよばれる
let observable4 = Observable.from([1,2,3,4,5])
observable3.subscribe { event in
    if let elemet = event.element {
        print(elemet)
    }
}

//MARK: -onNextで中身を入れている
let subscription4 = observable4.subscribe(onNext: { element in
    print(element)
})

subscription4.dispose()

let bag = DisposeBag()
Observable.of("A","B","C","D").subscribe(onNext: {element in
    print(element)
}).disposed(by: bag)


Observable<String>.create { observer in
    observer.onNext("F")
    observer.onNext("?")
    observer.onCompleted()
    
    return Disposables.create()
}.subscribe(onNext: { print($0) }, onError: { _ in print("error") }, onCompleted: { print("completed")}, onDisposed: { print("disposed")}).disposed(by: bag)


let subject = PublishSubject<String>()

//MARK: -呼ばれない。先にsubscribeしないと新聞読めないよね。
subject.onNext("Issue 1")


subject.subscribe(onNext: {element in print(element)}, onError: {_ in print("error")}, onCompleted: { print("completed") }, onDisposed: { print("disposed") }).disposed(by: bag)

subject.onNext("Issue 2")
subject.onNext("Issue 3")
subject.onCompleted()


let subject2 = BehaviorSubject(value: "Initial value")

//MARK: -BehaviourSubjectはあくまでもInitializerなので、書き換えられる。
subject2.onNext("Last Value")

subject2.subscribe({event in
    print(event)
})
subject2.onNext("Next value")

let subject3 = ReplaySubject<String>.create(bufferSize: 2)

//MARK: -ReplaySubjectを使うことによって、最後から数えて何番目まで読み込むかがわかる
subject3.onNext("hello 1")
subject3.onNext("hello 2")
subject3.onNext("hello 3")

subject3.subscribe({event in
    print(event)
})

subject3.onNext("hello 4")
subject3.onNext("hello 5")
subject3.onNext("hello 6")

print("[Subscription2]")
subject3.subscribe({
    print($0)
})

//MARK: -いつでもvalueを変えられる！！
let variable = Variable([String]())
variable.value.append(contentsOf: ["way","say","cake","make"])
variable.asObservable().subscribe({
    print($0)
})
variable.value.append("sake")

//MARK: - 静的である！！
let relay = BehaviorRelay(value: ["coke","soke"])
//基本的にはvalueを変えられないから、acceptメソッドが必要である。
//acceptメソッドを使って、initの中身を担保しながら、追加ができる。
//relay.accept(relay.value + ["mone","yone","corn","song"])

//ここで動的にvariableを変えることが可能！
var value = relay.value
value.append("tone")
//acceptがないと反映されない
relay.accept(value)


relay.asObservable().subscribe({
    print($0)
})

//bindでアンラップしている！
relay.bind { a in
    print(a)
}

//MARK: -ignorElement で全てのonNext内の値が無視される
//let strikes = PublishSubject<String>()
//strikes.ignoreElements().subscribe { _ in
//    print("Subscription is called")
//}.disposed(by: bag)
//
//strikes.onNext("A")
//strikes.onNext("B")
//strikes.onNext("C")
//strikes.onCompleted()

//MARK: -0,1,2で値がある時にしか呼ばれない
//strikes.elementAt(2).subscribe(onNext: { _ in
//    print("You are out!")
//}).disposed(by: bag)
//
//strikes.onNext("A")
//strikes.onNext("B")
//strikes.onNext("C")

//MARK: -filterすることができる。便利ね！！
//Observable.of(1,2,3,4,5,6,7).filter({$0 % 2 == 0}).subscribe(onNext: { value in
//    print(value)
//}).disposed(by: bag)

//MARK: -指定したインデックスまでスキップすることができる！！
//Observable.of("A","B","C","D","E","F").skip(3).subscribe(onNext: { value in
//    print(value)
//}).disposed(by: bag)

//MARK: -$0 % 2 == 0 == trueなものはスキップしてくれる。しかし、一度それに該当した場合、その機能をそれ以上は果たすことができない。
//Observable.of(2,2,3,4,4).skipWhile({$0 % 2 == 0}).subscribe(onNext: { value in
//    print(value)
//}).disposed(by: bag)



//MARK: -めっちゃ便利！triggerに何か入った時にしか、サブジェクトが呼ばれない。
//let subject = PublishSubject<String>()
//let trigger = PublishSubject<String>()
//
//subject.skipUntil(trigger).subscribe(onNext: { value in
//    print(value)
//}).disposed(by: bag)
//
//subject.onNext("A")
//subject.onNext("B")
//
//trigger.onNext("X")
//
//subject.onNext("C")


//MARK: -takeを使うことによって、指定したインデックスまでを読み込んでくれる。
//Observable.of(1,2,3,4,5,6).take(2).subscribe(onNext: { value in
//    print(value)
//}).disposed(by: bag)


//MARK: -これもskipWhileの逆で、指定した内容までを取得して、それ以降は機能しなくなる。
//Observable.of(2,4,3,4).takeWhile({$0 % 2 == 0}).subscribe(onNext: { value in
//    print(value)
//}).disposed(by: bag)


//MARK: -skipUntilの逆で、triggerに何かが入ってくるまで、その値を取得する。
//let subject = PublishSubject<String>()
//let trigger = PublishSubject<String>()
//
//subject.takeUntil(trigger).subscribe(onNext: { value in
//    print(value)
//}).disposed(by: bag)
//
//subject.onNext("A")
//subject.onNext("B")
//
//trigger.onNext("X")
//
//subject.onNext("C")

//MARK: -別々の要素をArrayにしてくれる。
//Observable.of(1,2,3,4,5).toArray().subscribe(onNext: {print($0)}).disposed(by: bag)

//MARK: -普通のmap!
//Observable.of(1,2,3,4,5).map({$0*2}).subscribe(onNext: {print($0)}).disposed(by: bag)

//struct Student {
//    var score: BehaviorRelay<Int>
//}
//let john = Student(score: BehaviorRelay(value: 75))
//let mary = Student(score: BehaviorRelay(value: 95))
//let anna = Student(score: BehaviorRelay(value: 60))

//MARK: -FlatMap
//let student = PublishSubject<Student>()
//student.asObservable().flatMap({
//    return $0.score.asObservable()
//}).subscribe(onNext: {
//    print($0)
//}).disposed(by: bag)
//
//student.onNext(john)
//john.score.accept(100)
//student.onNext(mary)
//student.onNext(anna)


//MARK: -一度、Observeしたら次に何度値を変えても変わらなくなる。
//student.asObservable().flatMapLatest({
//    return $0.score.asObservable()
//}).subscribe(onNext: {
//    print($0)
//}).disposed(by: bag)
//
//student.onNext(john)
//john.score.accept(100)
//student.onNext(mary)
//john.score.accept(50)
//student.onNext(anna)


//MARK: -startWith: 初めに値を代入できる。
//let numbers = Observable.of(2,3,4,5)
//let observable = numbers.startWith(1)
//observable.asObservable().subscribe(onNext: {print($0)}).disposed(by: bag)



//MARK: -concat: 配列をつなげることができる。
//let numbers = Observable.of(1,2,3,4,5)
//let numbers2 = Observable.of(6,7,8,9,10)
//let obsevable = Observable.concat([numbers,numbers2])
//obsevable.asObservable().subscribe(onNext: {print($0)}).disposed(by: bag)



//MARK: -merge: 別々の順番で呼ばれる要素を、その順番で呼び出してくれる。
//let leftSubject = PublishSubject<Int>()
//let rightSubject = PublishSubject<Int>()
//let source = Observable.of(leftSubject.asObservable(), rightSubject.asObservable())
//source.merge().asObservable().subscribe(onNext: {print($0)}).disposed(by: bag)
//
//leftSubject.onNext(4)
//leftSubject.onNext(3)
//rightSubject.onNext(5)
//rightSubject.onNext(7)
//leftSubject.onNext(1)
//rightSubject.onNext(10)


//MARK: -combineLatest: インデックス数を合っていない場合、最後に呼ばれたものをもとに数を合わせてくれる。
//let leftSubject = PublishSubject<Int>()
//let rightSubject = PublishSubject<Int>()
//let source = Observable.combineLatest(leftSubject, rightSubject) { L, R in
//    print("L:\(L), R:\(R)")
//}
//source.subscribe(onNext: { value in
//    print(value)
//}).disposed(by: bag)
//
//leftSubject.onNext(4)
//leftSubject.onNext(3)
//rightSubject.onNext(5)
//leftSubject.onNext(1)
//rightSubject.onNext(10)
//leftSubject.onNext(45)


//MARK: -withLatestFrom: 最後に入力されたものを取得。
//let button = PublishSubject<String>()
//let textField = PublishSubject<String>()
//
//let observable = button.withLatestFrom(textField)
//observable.subscribe(onNext: {print($0)}).disposed(by: bag)
//
//textField.onNext("Sw")
//textField.onNext("Swi")
//textField.onNext("Swif")
//textField.onNext("Swift")
//button.onNext("button1")
//textField.onNext("Swift Yeah!!")


//MARK: -reduce: この場合だと0から始めて、後の要素を足す！
//let source = Observable.of(1,2,3)
//source.reduce(0, accumulator: + ).subscribe(onNext: {print($0)}).disposed(by: bag)
////ちゃんとした書き方
//source.reduce(0) { summary, newValue in
//    return summary + newValue
//}.subscribe(onNext: {print($0)}).disposed(by: bag)


//MARK: -scan:　一つ一つ計算して足している。それを毎回printする。なので、最後にprintされるのが全ての合計。
//let source = Observable.of(1,2,3)
//source.scan(0) { summary, newValue in
//    return summary + newValue
//}.subscribe(onNext: {print($0)}).disposed(by: bag)
